# Tangbuting/milvus-client

A community-driven MoonBit client for the [Milvus](https://milvus.io/) vector database.

为 MoonBit 写的 Milvus 客户端。本地不做向量计算，只把你的调用翻译成 protobuf
请求发出去，再把响应解成 MoonBit 类型。协议代码随包发布，不需要自己跑
`protoc`，也没有 registry 之外的依赖。

本项目是社区项目，不是 Milvus 官方 SDK。"Milvus" 是 LF Projects, LLC 的商标，
Apache-2.0 不授予商标权，包名里的 "milvus" 只用来指明兼容对象。来源与许可见
文末一节。

## 特性与能力边界

覆盖一条完整的读写链路：建集合 / 索引 / 分区 → 写入 → 加载 → 检索 / 查询 →
刷盘 → 清理。

- **集合生命周期**：创建、描述、是否存在、列出、删除。
- **数据面**：insert、upsert、delete。
- **检索面**：search、query。
- **索引与分区**：索引的创建 / 描述 / 删除，`@index` 提供参数 builder；
  分区的创建 / 删除 / 是否存在 / 列出。
- **加载与刷盘**：`LoadCollection` / `ReleaseCollection` / `LoadPartitions` /
  `ReleasePartitions` / `GetLoadState` / `Flush` / `GetFlushState`。加载与刷盘
  返回可等待的任务，轮询默认 200ms 一次。
- **大结果集翻页**：`QueryIterator`（客户端侧主键游标）与 `SearchIterator`
  （服务端侧 v2 游标）。
- **跨 target**：`wasm` / `wasm-gc` / `js` / `native` 四个后端都编得过。
  只有真连 socket 的那部分要 `--target native`。
- **错误可分流**：传输失败可以原样重试，服务端拒绝要看错误码。

边界：

- 只交付 column-based 一路。写入用 `WriteColumn` 承接 `@column.ColumnValue`，
  回读用 `@column.Column`。row-based API 已排进
  [`docs/ROADMAP.md`](./docs/ROADMAP.md)，不是不打算做。
- `CreateCollection` 不会顺带建索引或 load 集合。上游 `IsFast()` 那种一步到位
  的便利被拆成了显式调用，顺序不能倒：建集合 → 建索引 → 加载（轮询到 `Loaded`）
  → 检索 / 查询。Milvus 拒绝加载没有索引的集合，也拒绝对未加载的集合检索。
- 其余尚未覆盖的能力见 [`docs/ROADMAP.md`](./docs/ROADMAP.md)。

## 安装

要求 MoonBit 工具链 0.10.14 或更高（`moon version --all` 查看）：

```sh
moon add Tangbuting/milvus-client
```

## 快速上手

连上 Milvus，建集合、建索引、加载、写入、检索、查询，最后清理掉。

```moonbit nocheck
///|
async fn quickstart() -> Unit raise @client.ClientError {
  // 1. 连上 Milvus
  let cfg = @transport.Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("default")
    .with_timeout_millis(5000)
  let (client, channel) = @native.connect(cfg)

  // 2. 建集合
  client.create_collection(
    @client.simple_create_collection_option("demo", dim=4),
  )

  // 3. 建索引
  client.create_index(
    @client.new_create_index_option(
      "demo",
      "vector",
      @index.new_flat_index(@index.MetricType::L2),
    ),
  )

  // 4. 加载，等到数据面就绪
  client.load_collection(@client.new_load_collection_option("demo")).wait()

  // 5. 写入三行
  let _ = client.insert(
    @client.new_write_option("demo", [
      @client.WriteColumn::new("id", @column.ColumnValue::Int64([1L, 2L, 3L])),
      @client.WriteColumn::new(
        "vector",
        @column.ColumnValue::FloatVector(4, [
          [0.1, 0.2, 0.3, 0.4],
          [0.5, 0.6, 0.7, 0.8],
          [0.9, 1.0, 1.1, 1.2],
        ]),
      ),
    ]),
  )

  // 6. 检索
  let hits = client.search(
    @client.new_search_option("demo", limit=3, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ]).with_anns_field("vector"),
  )
  ignore(hits)

  // 7. 按表达式查询
  let rows = client.query(
    @client.new_query_option("demo")
    .with_filter("id >= 1")
    .with_output_fields(["id", "vector"])
    .with_limit(10),
  )
  let ids : @column.Column = rows.column("id") catch { _ => return }

  // 8. 翻页
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 1000, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ])
    .with_anns_field("vector")
    .with_batch_size(500),
  ) catch {
    _ => return
  }
  while true {
    let page = iterator.next() catch {
      err => if err.is_end_of_iterator() { break } else { return }
    }
    ignore(page.hits.length())
  }
  let _ = iterator.close()

  // 9. 清理
  client.flush(@client.new_flush_option("demo")).wait()
  client.release_collection(@client.new_release_collection_option("demo"))
  client.drop_collection(@client.new_drop_collection_option("demo"))
  channel.close()
}
```

快速上手里的调用都对应 `client` 包的公共 API，逐个函数的签名和选项看各包
生成的 `.mbti`。

## 文档导航

仓库里的文档都在下面。

| 文档 | 内容 |
|---|---|
| [`README.mbt.md`](./README.mbt.md) | 本文件 |
| [`docs/ROADMAP.md`](./docs/ROADMAP.md) | 已规划未实现的能力 |
| [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md) | 开发流程、集成测试、上游同步、发布、需要注意的取舍 |
| [`AGENTS.md`](./AGENTS.md) | 协作约定与各包的实现约束 |
| [`proto/REPORT.md`](./proto/REPORT.md) | `protoc-gen-mbt` 对 Milvus proto 的支持度探针报告 |
| [`proto/upstream/PROVENANCE.md`](./proto/upstream/PROVENANCE.md) | `.proto` 快照的上游来源与锚定 commit |
| [`LICENSE`](./LICENSE) | Apache-2.0 许可证全文 |
| [`.githooks/README.md`](./.githooks/README.md) | pre-commit 钩子的启用方式 |

包结构：`entity`（schema 与向量类型）、`index`（索引参数 builder）、
`column`（响应回读）、`errors`（错误模型）、`transport` 与 `transport/native`
（配置与真连接）、`client` 与 `client/native`（门面与 RPC 编排）、
`proto/milvus/proto/*`（生成的协议包）。这些都只是 `Tangbuting/milvus-client`
里的包目录，生成物已入库。

## 贡献

欢迎提 Issue 和 PR。细节约定见 [`AGENTS.md`](./AGENTS.md)，开发与提交流程见
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。

## 来源与许可

本项目是 [milvus-io/milvus](https://github.com/milvus-io/milvus) 的 Go SDK
（`client/`，Apache-2.0，Copyright (c) LF AI & Data Foundation）向 MoonBit 的
移植与改写。协议定义取自独立的
[milvus-io/milvus-proto](https://github.com/milvus-io/milvus-proto) 仓库。

| 项 | 值 |
|---|---|
| 上游仓库 | `milvus-io/milvus`，`client/` 目录 |
| 基线 commit | `1bcc8cb1`（2026-09-30） |
| 上游许可 | Apache-2.0 |
| 上游版权 | Copyright (c) LF AI & Data Foundation |
| 本项目许可 | Apache-2.0（见 [`LICENSE`](./LICENSE)） |

上游同步与新文件归属声明的约定见 [`AGENTS.md`](./AGENTS.md)「许可与上游同步」
一节，同步流程见 [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。
