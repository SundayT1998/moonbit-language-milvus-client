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
// 步骤顺序是 Milvus 的硬要求，不能省也不能换：
//   create_collection → create_index → load_collection（轮询到 Loaded）
//   → search / query
// 少一步的报错各不相同：不建索引就 load 会得到 `index not found`
// （`IndexNotExist`），建了不 load 就检索会得到 `collection not loaded`
// （`CollectionNotLoaded`）—— 两种都在 #33 的 CI 上真踩过。

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

  // 5. 建索引。必须在加载之前：Milvus 对没有索引的集合拒绝加载，
  //    报 `index not found`。这里用 FLAT 而不是 HNSW/IVF —— 10 行的
  //    自检集合上暴力检索就是最优解，也不需要等索引构建。
  let index = @index.new_flat_index(@index.MetricType::L2)
  client.create_index(
    @client.new_create_index_option(collection, "vector", index),
  ) catch {
    err => return step_failed("5", "建索引失败：" + err.to_string())
  }
  let descriptions = client.describe_index(
    @client.new_describe_index_option(collection),
  ) catch {
    err => return step_failed("5", "查索引失败：" + err.to_string())
  }
  if descriptions.length() == 0 {
    return step_failed("5", "建完索引但 DescribeIndex 返回空")
  }
  println("[5] 向量字段已建 FLAT 索引")

  // 6. 加载集合。检索的前置条件：不加载的话服务端会回
  //    `collection not loaded`（错误码 `CollectionNotLoaded`）。
  //    LoadCollection 返回只代表请求被受理，数据面未必就绪，所以要
  //    轮询 get_load_state 直到 Loaded —— 直接接着检索会偶发失败。
  client.load_collection(@client.new_load_collection_option(collection)) catch {
    err => return step_failed("6", "加载集合失败：" + err.to_string())
  }
  match wait_loaded(client) {
    Ok(_) => ()
    Err(err) => return step_failed("6", err)
  }
  println("[6] 集合已加载")

  // 7. 检索：拿最后一行的向量当查询，L2 距离最近的一定是它自己。
  let query_vector = vectors[row_count - 1]
  let searched = client.search(
    @client.new_search_option(collection, 3, [
      @column.ColumnValue::FloatVector(dim, [query_vector]),
    ])
    .with_anns_field("vector")
    .with_metric_type(@index.MetricType::L2)
    .with_output_fields(["title"]),
  ) catch {
    err => return step_failed("7", "检索失败：" + err.to_string())
  }
  if searched.hits.length() == 0 {
    return step_failed("7", "检索没有命中")
  }
  let first = searched.hits[0]
  if first.score > 1.0e-3 {
    return step_failed("7", "自距离不为 0：score=\{first.score}")
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
      "7",
      "最近邻的 title 不符：期望 \{expected_title}，实际 \{self_title}",
    )
  }
  println(
    "[7] 检索命中 top1 title=" +
    self_title +
    " score=" +
    first.score.to_string(),
  )

  // 8. 查询：按 title 精确过滤后取两列，验回读的解码路径。
  //
  //    为什么不用 `id >= 5`：主键是 auto_id，服务端发的是时间戳量级的大整数
  //    （`pkg/common.AllocAutoID`：分配器给的序号再或上 clusterID 的位），
  //    `id >= 5` 对全部 10 行都为真，所以「期望 5，实际 10」。
  //    要过滤就得挑**本测试自己控制值**的列，这里用 title。
  //
  //    用 `in` 而不是范围：title 是字符串，`>= 'row-5'` 走字典序，
  //    行数一多（row-10）就与数值序分叉；列出要的那几个值没有歧义。
  //    字符串字面量用单引号，跟上游 Go SDK 测试表达式的写法一致。
  let expected_titles : Array[String] = []
  for i = 5; i < row_count; i = i + 1 {
    expected_titles.push("row-" + i.to_string())
  }
  let filter = "title in [" +
    expected_titles.map(t => "'" + t + "'").join(", ") +
    "]"
  let queried = client.query(
    @client.new_query_option(collection)
    .with_filter(filter)
    .with_output_fields(["id", "title"]),
  ) catch {
    err => return step_failed("8", "查询失败：" + err.to_string())
  }
  if queried.len() != expected_titles.length() {
    return step_failed(
      "8",
      "查询行数不符：期望 \{expected_titles.length()}，实际 \{queried.len()}",
    )
  }
  let title_column = match queried.column("title") {
    Some(c) => c
    None => return step_failed("8", "结果里没有 title 列")
  }
  // 逐行解码，并把结果收成集合：Milvus 的 query 不保证返回顺序，
  // 断言「集合相等」比断言「第 i 行等于第 i 个期望值」靠谱。
  let seen : Array[String] = []
  for i = 0; i < title_column.len(); i = i + 1 {
    let actual = title_column.get_as_string(i) catch {
      err =>
        return step_failed(
          "8",
          "title 第 \{i} 行解码失败：" +
          @client.column_error_message(err),
        )
    }
    seen.push(actual)
  }
  for expected in expected_titles {
    if !seen.contains(expected) {
      return step_failed(
        "8",
        "查询结果里缺 title=\{expected}：实际 \{seen.join(", ")}",
      )
    }
  }
  let id_column = match queried.column("id") {
    Some(c) => c
    None => return step_failed("8", "结果里没有 id 列")
  }
  if id_column.len() != expected_titles.length() {
    return step_failed("8", "id 列行数与 title 列不一致")
  }
  println(
    "[8] 查询按表达式返回 \{queried.len()} 行，title 集合正确（id 列已回读）",
  )

  // 9. 收尾：把自检集合删掉，下次跑还是干净的。
  client.drop_collection(@client.new_drop_collection_option(collection)) catch {
    err => return step_failed("9", "删除集合失败：" + err.to_string())
  }
  println("[9] 集合已清理")
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
/// 轮询到集合真的 Loaded。
///
/// `load_collection` 的返回只表示服务端受理了请求，数据面就绪是异步的。
/// 这里给一个宽松的上限（60s）就够：CI 上加载一个 10 行的小集合是秒级的，
/// 真走到超时说明服务端出问题了，该报错而不是无限等。
///
/// 返回 `Err` 时是已经带好步骤名的失败文本。
async fn wait_loaded(client : @client.Client) -> Result[Unit, String] {
  let option = @client.new_describe_collection_option(collection)
  let limit = 120
  for i = 0; i < limit; i = i + 1 {
    let state = client.get_load_state(option) catch {
      err => return Err("查加载状态失败：" + err.to_string())
    }
    match state {
      @client.CollectionLoadState::Loaded => return Ok(())
      @client.CollectionLoadState::NotExist =>
        return Err("加载中集合消失了")
      @client.CollectionLoadState::Unknown(code) =>
        return Err("无法识别的加载状态：" + code.to_string())
      _ => ()
    }
    // 每半秒问一次；120 次即最长等 60s。
    @async.sleep(500)
  }
  Err("等集合加载超时（60s 内没到 Loaded）")
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
