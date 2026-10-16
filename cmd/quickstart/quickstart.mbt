// README「快速上手」的逐字副本 —— 由 `moon check` 真编译。
//
// 改 README 那段示例时**同步改这里**：两边必须一模一样，否则门禁就形同虚设。
// 之所以要留一份副本而不是直接检查 README：MoonBit 只检查「当前包自己目录下」
// 的 `README.mbt.md`，仓库根那份在根包下，而示例引了 `client/native`
// （native-only），挂到根包上整棵依赖图都编不过（见同目录 `moon.pkg`）。
//
// `moon check` 走得到本包，所以示例里的类型错误、写错的函数名、对不上的
// 参数都会在 CI 里报出来 —— 这正是 `moon fmt` 只肯给 ```moonbit 加 `nocheck`
// 而盖掉的东西。

///|
async fn quickstart() -> Unit {
  // 1. 连上 Milvus
  let cfg = @transport.Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("default")
    .with_timeout_millis(5000)
  let (client, channel) = @native.connect(cfg) catch {
    err => {
      println("建连失败：" + err.to_string())
      return
    }
  }

  // 2. 建集合。主键 auto_id 由服务端发号，写入时不用给；另外带一个标量字段，
  //    下面第 7 步按它过滤。
  let schema = @entity.CollectionSchema::new([
    @entity.Field::new("id", @entity.DataType::Int64)
    .as_primary_key()
    .as_auto_id(),
    @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(128) catch {
      _ => return
    },
    @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(4) catch {
      _ => return
    },
  ])
  client.create_collection(@client.new_create_collection_option("demo", schema)) catch {
    err => {
      println("建集合失败：" + err.to_string())
      return
    }
  }

  // 3. 建索引。必须在加载之前，Milvus 拒绝加载没有索引的集合
  client.create_index(
    @client.new_create_index_option(
      "demo",
      "vector",
      @index.new_flat_index(@index.MetricType::L2),
    ),
  ) catch {
    err => {
      println("建索引失败：" + err.to_string())
      return
    }
  }

  // 4. 加载，等到数据面就绪。返回只代表请求被受理，就绪是异步的
  client.load_collection(@client.new_load_collection_option("demo")).wait() catch {
    err => {
      println("加载失败：" + err.to_string())
      return
    }
  }

  // 5. 写入三行
  ignore(
    client.insert(
      @client.new_write_option("demo", [
        @client.WriteColumn::new(
          "title",
          @column.ColumnValue::VarChar(["alpha", "beta", "gamma"]),
        ),
        @client.WriteColumn::new(
          "vector",
          @column.ColumnValue::FloatVector(4, [
            [0.1, 0.2, 0.3, 0.4],
            [0.5, 0.6, 0.7, 0.8],
            [0.9, 1.0, 1.1, 1.2],
          ]),
        ),
      ]),
    ),
  ) catch {
    err => {
      println("写入失败：" + err.to_string())
      return
    }
  }

  // 6. 检索
  let hits = client.search(
    @client.new_search_option("demo", 3, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ]).with_anns_field("vector"),
  ) catch {
    err => {
      println("检索失败：" + err.to_string())
      return
    }
  }
  ignore(hits)

  // 7. 按表达式查询。过滤用的 `title` 是自己写的列：主键由 auto_id 发，
  //    是 Snowflake 量级的大整数，`id >= 1` 等于全表通过。
  //    `output_fields` 要逐点名，不能用 `*`、也不能留空，否则服务端
  //    不回列名，按名取列会取空。
  let rows = client.query(
    @client.new_query_option("demo")
    .with_filter("title in [\"alpha\",\"beta\"]")
    .with_output_fields(["id", "title"])
    .with_limit(10),
  ) catch {
    err => {
      println("查询失败：" + err.to_string())
      return
    }
  }
  ignore(rows)

  // 8. 翻页。走到末尾会自己收尾，`close` 是幂等的。
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 1000, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ])
    .with_anns_field("vector")
    .with_batch_size(500),
  ) catch {
    err => {
      println("建迭代器失败：" + err.to_string())
      return
    }
  }
  while true {
    let page = iterator.next() catch {
      err => if err.is_end_of_iterator() { break } else { return }
    }
    ignore(page.hits.length())
  }
  ignore(iterator.close()) catch {
    _ => ()
  }

  // 9. 清理
  client.flush(@client.new_flush_option("demo")).wait() catch {
    _ => ()
  }
  client.release_collection(@client.new_release_collection_option("demo")) catch {
    _ => ()
  }
  client.drop_collection(@client.new_drop_collection_option("demo")) catch {
    _ => ()
  }
  channel.close()
  println("quickstart ok")
}

///|
fn main {
  @async.run_async_main(quickstart)
}
