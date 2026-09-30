// 端到端集成自检：连一个真实 Milvus，跑通「建表 → 写入 → 检索 → 查询」。
//
// CI 里由 `.cnb.yml` 的 integration job 驱动：先用 scripts/milvus-start.sh
// 起官方 v3 镜像的 standalone 容器，再跑本程序，最后收尾停容器。
// 本地等价用法：
//   scripts/milvus-start.sh
//   moon run cmd/integration -- 127.0.0.1:19530
//   scripts/milvus-stop.sh
//
// 与 `cmd/main`（传输层自检）的分工：那个只验连得上、metadata 发得出；
// 这个走完整的客户端门面，验的是「协议编排在真服务端上确实成立」。
// 退出码非 0 即失败，CI 直接看退出码。
//
// 本程序只用**已实现**的那部分门面。`client` 目前没有 CreateIndex /
// DescribeIndex / LoadCollection（见 Issue #36），所以这里不带索引，
// 依赖服务端的暴力检索。等索引那层补上，再在这里加上建索引一步。

///|
/// 自检用的集合名与向量维度。固定值，便于失败时人工复现。
let collection : String = "moonbit_ci_selfcheck"

///|
let dim : Int = 4

///|
/// 写入的行数。
let row_count : Int = 10

///|
/// 每一步失败时的文本：带上是哪一步、为什么。
fn step_failed(step : String, reason : String) -> String {
  "[\{step}] \{reason}"
}

///|
fn main {
  let args = @env.args()
  let address = match args {
    [_, addr, ..] => addr
    _ => "127.0.0.1:19530"
  }
  @async.run_async_main(() => run(address))
}

///|
async fn run(address : String) -> Unit {
  let outcome = check_all(address)
  match outcome {
    "" => println("\n集成自检全部通过")
    msg => {
      println("\n集成自检失败：" + msg)
      // 非 0 退出码；失败细节已经打在 stdout 里。
      abort(msg)
    }
  }
}

///|
/// 建连后跑各步。返回空串表示全过，否则是带步骤名的失败文本。
async fn check_all(address : String) -> String {
  let cfg = @transport.Config::new(address)
    .with_token("root:Milvus")
    .with_timeout_millis(10_000)
  let (client, channel) = @native.connect(cfg) catch {
    err => return step_failed("连接", "建连失败：" + err.to_string())
  }
  let outcome = check_steps(client)
  channel.close()
  outcome
}

///|
async fn check_steps(client : @client.Client) -> String {
  // 1. 连得上：describe 一个不存在的集合应当报 CollectionNotFound，
  //    而不是传输失败 —— 说明 gRPC 通、服务端在应答、认证也过了。
  let probe = @client.new_describe_collection_option(collection)
  // 上一轮的集合还在（说明上次没清干净）也算连得上，第 2 步会清掉。
  let probe_outcome = probe_collection(client, probe)
  let _ = match probe_outcome {
    Ok(_) => ()
    Err(err) =>
      if client_error_is_not_found(err) {
        println("[1] 连接正常（探针集合不存在，符合预期）")
      } else {
        return step_failed("1", "连接/认证失败：" + err.to_string())
      }
  }

  // 2. 清场：上一轮跑剩的集合先删掉，保证幂等。
  client.drop_collection(@client.new_drop_collection_option(collection)) catch {
    _ => ()
  }

  // 3. 建集合：显式 schema，主键 auto_id，向量字段 dim=4。
  let schema = build_schema()
  client.create_collection(
    @client.new_create_collection_option(collection, schema),
  ) catch {
    err => return step_failed("3", "建集合失败：" + err.to_string())
  }
  println("[3] 集合已创建")

  // 4. 写入 10 行。向量取 [i, 2i, 3i, 4i]，检索结果可预期。
  //    不带主键列：auto_id 由服务端发号，这本身也是一条要验的路径。
  let titles : Array[String] = []
  let vectors : Array[Array[Float]] = []
  for i = 0; i < row_count; i = i + 1 {
    titles.push("row-" + i.to_string())
    vectors.push([
      Float::from_int(i),
      Float::from_int(i * 2),
      Float::from_int(i * 3),
      Float::from_int(i * 4),
    ])
  }
  let inserted = client.insert(
    @client.new_write_option(collection, [
      @client.WriteColumn::new("title", @column.ColumnValue::VarChar(titles)),
      @client.WriteColumn::new(
        "vector",
        @column.ColumnValue::FloatVector(dim, vectors),
      ),
    ]),
  ) catch {
    err => return step_failed("4", "写入失败：" + err.to_string())
  }
  if inserted.insert_count != row_count.to_int64() {
    return step_failed(
      "4",
      "写入计数不符：期望 \{row_count}，实际 \{inserted.insert_count}",
    )
  }
  let _ = match inserted.ids {
    Some(_) => ()
    None => return step_failed("4", "auto_id 的写入没有回主键")
  }
  println("[4] 已写入 \{row_count} 行，计数与主键已确认")

  // 5. 检索：拿最后一行的向量当查询，L2 距离最近的一定是它自己。
  let query_vector = vectors[row_count - 1]
  let searched = client.search(
    @client.new_search_option(collection, 3, [
      @column.ColumnValue::FloatVector(dim, [query_vector]),
    ])
    .with_anns_field("vector")
    .with_metric_type(@index.MetricType::L2)
    .with_output_fields(["title"]),
  ) catch {
    err => return step_failed("5", "检索失败：" + err.to_string())
  }
  if searched.hits.length() == 0 {
    return step_failed("5", "检索没有命中")
  }
  let first = searched.hits[0]
  if first.score > 1.0e-3 {
    return step_failed("5", "自距离不为 0：score=\{first.score}")
  }
  let self_title = match first.fields.get("title") {
    Some(@column.ColumnValue::VarChar(v)) =>
      if v.length() > 0 {
        v[0]
      } else {
        ""
      }
    Some(@column.ColumnValue::String(v)) =>
      if v.length() > 0 {
        v[0]
      } else {
        ""
      }
    _ => ""
  }
  let expected_title = "row-" + (row_count - 1).to_string()
  if self_title != expected_title {
    return step_failed(
      "5",
      "最近邻的 title 不符：期望 \{expected_title}，实际 \{self_title}",
    )
  }
  println(
    "[5] 检索命中 top1 title=" +
    self_title +
    " score=" +
    first.score.to_string(),
  )

  // 6. 查询：按表达式取两列，验回读的解码路径。
  let queried = client.query(
    @client.new_query_option(collection)
    .with_filter("id >= 5")
    .with_output_fields(["id", "title"]),
  ) catch {
    err => return step_failed("6", "查询失败：" + err.to_string())
  }
  if queried.len() != 5 {
    return step_failed(
      "6",
      "查询行数不符：期望 5，实际 \{queried.len()}",
    )
  }
  let title_column = match queried.column("title") {
    Some(c) => c
    None => return step_failed("6", "结果里没有 title 列")
  }
  for i = 0; i < title_column.len(); i = i + 1 {
    let expected = "row-" + (i + 5).to_string()
    let cell = title_column.get(i) catch {
      err =>
        return step_failed(
          "6",
          "title 第 \{i} 行解码失败：" +
          @client.column_error_message(err),
        )
    }
    let actual = match cell {
      @column.Cell::VarChar(s)
      | @column.Cell::String(s)
      | @column.Cell::Text(s) => s
      _ => ""
    }
    if actual != expected {
      return step_failed(
        "6",
        "title 第 \{i} 行不符：期望 \{expected}，实际 \{actual}",
      )
    }
  }
  println("[6] 查询按表达式返回 5 行，列内容正确")

  // 7. 收尾：把自检集合删掉，下次跑还是干净的。
  client.drop_collection(@client.new_drop_collection_option(collection)) catch {
    err => return step_failed("7", "删除集合失败：" + err.to_string())
  }
  println("[7] 集合已清理")
  ""
}

///|
/// 自检用的 schema。
///
/// 单拎出来是因为 `with_max_length` / `with_dim` 会抛 `SchemaError`，
/// 而 `check_steps` 只回错误文本、不带 raise。参数是写死的常量，
/// 这里失败说明代码本身有问题，直接崩比假装通过好。
fn build_schema() -> @entity.CollectionSchema {
  let fields : Array[@entity.Field] = [
    @entity.Field::new("id", @entity.DataType::Int64)
    .as_primary_key()
    .as_auto_id(),
  ]
  fields.push(
    @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(128) catch {
      _ => abort("title 字段的 max_length 非法")
    },
  )
  fields.push(
    @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(dim) catch {
      _ => abort("vector 字段的 dim 非法")
    },
  )
  @entity.CollectionSchema::new(fields)
}

///|
/// 探一下集合能不能描述。
///
/// 收成 `Result` 而不是就地 `catch`：这里既要能报「不存在」，又不能把
/// 「服务端拒绝」当成失败吞掉，用 `Result` 把两种情况分开带出来最直白。
async fn probe_collection(
  client : @client.Client,
  option : @client.DescribeCollectionOption,
) -> Result[@client.CollectionDescription, @client.ClientError] {
  let described = client.describe_collection(option) catch {
    err => return Err(err)
  }
  Ok(described)
}

///|
/// 这次失败是不是「集合不存在」。
///
/// 与 `has_collection` 用同一套判断：Milvus 把错误码放在响应体的
/// `common.Status` 里而不是 gRPC status，所以要经 `ClientError::Server` 看码。
fn client_error_is_not_found(err : @client.ClientError) -> Bool {
  match err {
    Server(merr) =>
      @errors.error_code(Some(merr)) ==
      @errors.error_code(Some(@errors.err_collection_not_found()))
    _ => false
  }
}
