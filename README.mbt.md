# Tangbuting/milvus-client

A community-driven MoonBit client for the [Milvus](https://milvus.io/) vector database.

为 MoonBit 写的 Milvus 客户端：薄客户端，本地不做任何向量计算 —— 把你的调用
翻译成 protobuf 请求、发出去、把响应解回 MoonBit 类型。协议代码（`.proto`
生成的包）随包一起发布，装上就能用，不需要你自己跑 `protoc`。

> **本项目是社区项目，不是 Milvus 官方 SDK。** "Milvus" 是 LF Projects, LLC
> 的商标；Apache-2.0 不授予商标权，包名中的 "milvus" 仅为指明兼容对象的
> 描述性使用。来源、改写定性与同步策略见「[来源与许可](#来源与许可)」。

## 特性

- **完整读写链路** —— 建集合 / 索引 / 分区 → 写入 → 加载 → 检索 / 查询 →
  刷盘 → 清理，一条链路都在。
- **跨 target** —— 模块 `preferred_target = "wasm"`，`wasm` / `wasm-gc` /
  `js` / `native` 四个后端都编得过。发字节这件事被抽成 `Unary` 函数值，
  所以测试和 wasm 下不需要真连接。
- **协议自带** —— 生成的协议包是本模块自己的包目录，没有第二个模块，
  也没有 registry 之外的依赖。
- **错误可分流** —— 传输失败可以原样重试，服务端拒绝要看错误码；
  `is_transport_failure` / `is_client_error_retryable` 用来分流。
- **翻页两条路** —— `QueryIterator`（客户端侧主键游标）与
  `SearchIterator`（服务端侧 v2 游标）。
- **零依赖的数值实现** —— BF16 / FP16 手写转换，逐位对齐 IEEE-754 与上游
  `ml_dtypes.bfloat16`。

暂时没做、但已列进规划的（row-based API、schema 缓存等）见
[`docs/ROADMAP.md`](./docs/ROADMAP.md)。

## 能力边界

覆盖的是一条完整读写链路，按依赖方向排。更细的覆盖范围（各包支持哪些列类型、
哪些枚举、哪些边界）在下面的小节里。

- **集合生命周期** —— 创建 / 描述 / 是否存在 / 列出 / 删除，Option 构造函数名
  与默认值对齐上游。
- **数据面** —— insert / upsert / delete。
- **检索面** —— search / query。
- **索引与分区** —— 索引的创建 / 描述 / 删除（`@index` 提供参数 builder）；
  分区（创建 / 删除 / 是否存在 / 列出）。
- **加载与数据生命周期** —— `LoadCollection` / `ReleaseCollection` /
  `LoadPartitions` / `ReleasePartitions` / `GetLoadState`）；刷盘（`Flush` /
  `GetFlushState`）。加载与刷盘返回**可等待**的任务，轮询语义与上游一致
  （默认 200ms 间隔）。
- **大结果集翻页** —— `QueryIterator`（客户端侧主键游标）与 `SearchIterator`
  （服务端侧 v2 游标）。

**只交付 column-based 一路**：写入用 `WriteColumn` 承接 `@column.ColumnValue`，
回读用 `@column.Column`。row-based API 在
[`docs/ROADMAP.md`](./docs/ROADMAP.md) 里排期，不是「不打算做」。

`CreateCollection` 不会顺带建索引或 load 集合 —— 上游 `IsFast()` 那条路是
「一步到位」的便利，本移植把它拆成显式调用。**顺序不能倒**：
`create_collection` → `create_index` → `load_collection`（轮询到 `Loaded`）
→ `search` / `query`，完整链路见下面「快速上手」。Milvus 拒绝加载没有索引的
集合，也拒绝对未加载的集合检索；加载是异步的，`load_collection` 返回不代表就绪。

## 安装

要求 MoonBit 工具链 **0.10.14 或更高**（`moon version --all` 查看）：

```sh
moon add Tangbuting/milvus-client
```

包名是 `Tangbuting/milvus-client`，版本随 `moon.mod` 走；`moon add` 会把当前
版本写进依赖清单。

本模块没有别的非 registry 依赖：协议代码就是本模块自己的包目录，
不存在「装上了但依赖没上 registry」的情况。

<details>
<summary>从源码构建 / 包结构 / 目标平台</summary>

从源码构建 —— 本仓库只有一个模块，生成物也已入库，签出后直接就能编：

```sh
moon check --target all && moon test --target all
```

改了 `proto/trimmed/*.proto` 才需要重新生成（需 `protoc`）：

```sh
proto/tools/gen.sh trimmed
```

包结构 —— 单模块，下面每一行都是 `Tangbuting/milvus-client` 里的包：

| 包 | 内容 |
|---|---|
| `entity` | Schema / Field / Vector 抽象，含 BF16 手写转换 |
| `index` | 索引参数 builder、`MetricType` / `IndexType` 枚举、索引 RPC 入参与响应解析 |
| `column` | 响应 `FieldData` → 列容器反序列化，查询/检索回读的落点 |
| `proto/milvus/proto/*` | 生成的协议包（`common` / `milvus` / `msg` / `schema`）与四个 wire 往返测试包 |
| `proto/`（源码侧） | 上游 `.proto` 快照、裁剪集、代码生成与可行性结论，见 `proto/REPORT.md` |
| `errors` | Milvus `common.Status` → MoonBit 错误模型 |
| `transport` | 配置、metadata 组装、gRPC status —— 跨 target |
| `transport/native` | 真连 socket 的 Channel 实现 —— native 专属 |
| `client` | Client 门面与核心 RPC 编排：collection / partition / load / flush / insert / upsert / delete / search / query / 迭代器 |
| `client/native` | 把 `client` 的 unary 调用接到真实连接上 —— native 专属 |

迭代器在 `client/iterator.mbt`，与 `client` 同包。

目标平台：`client` / `entity` / `index` / `column` / `errors` / `transport`
在四个后端下都编得过；真连 socket 的 `client/native` + `transport/native`
是 native 专属，用它们要 `--target native`。

</details>

## 快速上手

一条完整链路：连上 Milvus → 建集合 → 建索引 → 加载 → 写入 → 检索 → 查询 →
翻页 → 清理。**顺序是硬要求**：Milvus 拒绝加载没有索引的集合，也拒绝对未加载
的集合检索。

```moonbit nocheck
///|
async fn quickstart() -> Unit raise @client.ClientError {
  // 1. 连上（native 专属）。transport 配置跨 target，真连接才是 native 的。
  let cfg = @transport.Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("default")
    .with_timeout_millis(5000)
  let (client, channel) = @native.connect(cfg)

  // 2. 建集合：给名字和维度就够，默认 id/vector + 动态字段
  client.create_collection(
    @client.simple_create_collection_option("demo", dim=4),
  )

  // 3. 建索引（10 行的集合上暴力检索就是最优解，也不用等索引构建）
  client.create_index(
    @client.new_create_index_option(
      "demo",
      "vector",
      @index.new_flat_index(@index.MetricType::L2),
    ),
  )

  // 4. 加载：返回只表示请求被受理，数据面就绪是异步的
  client.load_collection(@client.new_load_collection_option("demo")).wait()

  // 5. 写入：写入前本地校验列行数、向量 dim、空列
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

  // 6. 检索：最近邻
  let hits = client.search(
    @client.new_search_option("demo", limit=3, [
      @column.ColumnValue::FloatVector(4, [[0.1, 0.2, 0.3, 0.4]]),
    ]).with_anns_field("vector"),
  )
  ignore(hits)

  // 7. 按表达式查询：必须逐点名 output_fields，别用 "*"、也别留空
  let rows = client.query(
    @client.new_query_option("demo")
    .with_filter("id >= 1")
    .with_output_fields(["id", "vector"])
    .with_limit(10),
  )
  // 回读的列：读错类型报 ColumnError，不做隐式转换
  let ids : @column.Column = rows.column("id") catch { _ => return }

  // 8. 翻页：服务端侧 v2 游标，nq 恒为 1
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

### 传输层的配置与自检

配置的 builder 跨 target 可用；自检程序连上后发一次 Health/Check，失败以非
0 退出码结束（建连失败、Health/Check 报非超时错误都算失败；**调用超时反而算
通过** —— 那正是它要验的东西）：

```sh
moon run --target native cmd/main -- 127.0.0.1:19530 root:Milvus default
```

判断失败是不是超时：

```moonbit nocheck
match ... {
  // ...
} catch {
  err => if err.is_deadline_exceeded() { /* 超时 */ }
}
```

### 本地测试用假传输

上层调用只要给一个 `Unary` 函数值就能跑，所以测试与 wasm 下不需要真连接：

```moonbit nocheck
///|
let client = @milvus_client.new_client(cfg, my_unary)
```

### entity：schema 与数值转换

```moonbit nocheck
let schema = @entity.CollectionSchema::new([
  @entity.Field::new("id", @entity.DataType::Int64).as_primary_key().as_auto_id(),
  @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(512),
  @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(768),
])
schema.validate() // 本地就挡下服务端会拒绝的 schema
```

- `DataType` 的数值与 `schema.proto` 逐条对齐，`entity/datatype_test.mbt`
  用断言锁住。改动等于改协议。
- `dim` / `max_length` 不是 `FieldSchema` 的字段，服务端从 `type_params` 里读，
  所以 `Field::type_params_pairs()` 负责把它们拼出来，`type_params` 留作其余
  条目的出口。
- BF16 / FP16 是手写的，逐位对齐 IEEE-754 与上游 `ml_dtypes.bfloat16`，
  零依赖。稀疏向量保留 `(indices, values)` 表示。

### column：响应回读

`column` 把响应里的 `FieldData` 解成列，`Query` / `Search` 的回读都从这里过。

```moonbit nocheck
let col = @column.from_field_data(field_data, begin=0, end=-1)
for i = 0; i < col.len(); i = i + 1 {
  if col.is_null(i) {
    continue
  }
  let v = col.get_as_int64(i) // 读错类型报 ColumnError，不做隐式转换
}
```

- 支持 Bool / Int8~Int64 / Float / Double / String / VarChar / Text /
  Timestamptz / Geometry / JSON / Array，以及全部向量类型。
- 窄整数按位宽有符号收窄：服务端把 `Int8` 放在 `int32` 数组里，`0xFF` 读成 -1。
- 可空列两种布局都认：`valid_data` 与数据等长（行满）或等于有效数（紧凑）。
  两处有效性位图不一致时报错，不挑一边。
- 动态字段（JSON）以 **JSON 字符串**取回，不做路径查询。

### index：参数 builder

`index` 包的参数 builder 与上游 Go SDK 的 `client/index` 对齐：键名、默认值、
枚举字面量逐条一致，**非法组合在构造期报错**，而不是等一次 RPC 往返。

```moonbit nocheck
// HNSW：默认 M=16、efConstruction=200，与上游一致
let idx = @index.new_hnsw_index(@index.MetricType::COSINE, m=32)

// 补构建器未建模的参数
let extra = @index.IndexParams::new()
extra.set("refine", "true")
let idx2 = @index.new_hnsw_index(@index.MetricType::L2).with_extra_params(extra)

// 越界在构造期被拦下
let _ = @index.new_hnsw_index(@index.MetricType::L2, m=1)
// raise IndexParamError::OutOfRange(key="M", value=1, expected=">= 2")
```

### 迭代器

Milvus 服务端对单次返回有上限，超过就得翻页。两条路，选一条 —— 完整示例见
上面「快速上手」第 8 步。

- `QueryIterator` 是**客户端侧**游标：`DescribeCollection` 拿主键，之后每批把
  `pk > last` 拼进 `expr` 往后挪。不依赖服务端版本；要求主键是 `Int64` /
  `VarChar`，否则建立时就报 `Setup`。
- `SearchIterator` 是**服务端侧** v2 游标：翻页凭据在响应里跟命中一起回来。
  `nq` 恒为 1，多给会报 `Setup`；依赖服务端实现 SearchIterator V2。

要点：

- 走到末尾报 `IteratorError::EndOfIterator`，不是故障。`is_end_of_iterator`
  用来把它从 `while` 里放出来；`IteratorError::Closed` 才是「迭代器已经关了」。
- `close` 之后或翻完之后再问，一律报 `EndOfIterator` / `Closed`，不会又发
  一发请求。
- `SearchIterator::close` 会**真的**发一次空检索把服务端会话收掉（服务端侧
  游标不会自己过期），翻到末尾时也自动收一次。失败不往上抛 —— 调用方多半是
  在 `defer` 里关的。
- `QueryIterator` 在服务端没有会话，`close` 只是个本地标记。
- `with_limit` 是整体上限：只决定「还发不发下一次请求」，**不跨批截断**。
  上游的 `SearchIterator` 会切短超出上限的那一批，本移植统一不切。

### request 编排的约定

- `search_params` 固定写全 `anns_field` / `topk` / `offset` / `metric_type` /
  `round_decimal` / `ignore_growing` / `params` 七个键，调用方的
  `with_search_param` 最后覆盖 —— 与上游的键集合和顺序一致。
- `has_collection` 走 `DescribeCollection`，把 `CollectionNotExists` 当 `false`
  而不是失败；`has_partition` 走真 `HasPartition` RPC。两处不同是上游的选择。
- 未显式设一致性等级时，请求里 `use_default_consistency` 为真、等级填
  `Bounded`，由服务端决定最终档位。
- `LoadTask::wait` / `FlushTask::wait` 与上游 `Await` 一致，**先等一个间隔再
  查第一次**；间隔默认 200ms。取消会翻成 `Code::Cancelled` 的 `Transport` 错误。
- 状态枚举都保留 `Unknown` 岔路（`CollectionLoadState::Unknown` /
  `IndexState::Unknown`）。别把它们并进 `NotLoad` / `None` —— 那会把「没见过的
  状态」当成「什么都没发生」，然后无限等下去。

## 已知限制

- 传输失败与「服务端拒绝」是两个不同的 `ClientError` 分支：
  `Transport` 可以原样重试，`Server` 要看 `@errors.is_retryable_err`
  （只看服务端下发的 `retriable`，不做本地猜测）。
- 不缓存集合 schema，所以 insert / upsert 不带 `schema_timestamp`，
  也没有上游那套 schema-mismatch 自动重试。schema 变更后由调用方重新描述集合。
  补缓存已列进 [`docs/ROADMAP.md`](./docs/ROADMAP.md)。
- `WriteColumn` 不支持 `Array` 列：元素的 `DataType` 没法从值本身推出来，
  要写数组字段得先补一个带元素类型的列类型。
- `Query` 的列名来自 `FieldData.field_name`。服务端在返回**全部字段**时
  （`with_output_fields(["*"])`，或一个 `output_fields` 都不给）不填
  `field_name`，只给 `field_id`：列名会全空、行数读成 0，症状酷似「过滤条件
  被忽略」。契约是：逐点名 `output_fields`，别用 `*`、也别留空。
- `Query` 的 `limit` 不预置，交给服务端默认上限；要断言确定行数就显式
  `with_limit(n)`。也别拿主键当行号筛数据：`auto_id` 发的是 Snowflake ID，
  `id >= 5` 在 18 位的主键上等于全表通过。
- Binary / Int8 向量列在 `@column.ColumnValue` 里是「逐行一块字节」，
  行内字节数按 `dim`（binary 按 `dim / 8`）校验。
- 迭代器不做跨批截断：`with_limit(10)` 配 `with_batch_size(100)` 时你一次拿到
  100 行，而不是 10 行。
- `SearchIterator` 依赖服务端实现 SearchIterator V2。老服务端不给
  `search_iterator_v2_results`，`next` 会报 `Setup`（上游这里是
  `ErrServerVersionIncompatible`）。

## 文档导航

除了参赛用的 `docs/项目申报书.md`（有成文格式要求，不属于这套分工），
仓库里的文档都在下面。

| 文档 | 内容 |
|---|---|
| [`README.mbt.md`](./README.mbt.md) | 本文件 —— 面向使用者：定位、安装、快速上手、能力边界、已知限制 |
| [`docs/ROADMAP.md`](./docs/ROADMAP.md) | 已规划未实现的能力（row-based API、schema 缓存等） |
| [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md) | 开发流程、集成测试、交付范围、验收标准、发布流程、被推翻的方案与理由 |
| [`AGENTS.md`](./AGENTS.md) | 协作约定与各包的实现约束（给 AI / 贡献者） |
| [`proto/REPORT.md`](./proto/REPORT.md) | `protoc-gen-mbt` 对 Milvus proto 的支持度探针报告（含已知缺陷与退路） |
| [`proto/upstream/PROVENANCE.md`](./proto/upstream/PROVENANCE.md) | `.proto` 快照的上游来源与锚定 commit |
| [`LICENSE`](./LICENSE) | Apache-2.0 许可证全文 |
| [`.githooks/README.md`](./.githooks/README.md) | pre-commit 钩子的启用方式 |

## 贡献

```sh
moon check --target all && moon test --target all
```

- **改代码走 PR**，别直接推 `main`。
- 提交前跑一遍上面的命令；`moon fmt` 与 `moon info` 不应留下额外 diff
  （`.mbti` 变了说明对外接口变了，值得在 PR 里说明）。
- 文档分工：README 面向使用者，只讲怎么用和为什么这么设计；过程与归档在
  `docs/DEVELOPMENT.md`；**Issue / PR 是对话现场，不是档案室** —— 讨论完把
  结论写进文档，不要回贴长总结。细节见 [`AGENTS.md`](./AGENTS.md)。
- `proto/milvus/proto/` 是生成物，**不要手改**。改 `.proto` 或
  `proto/tools/gen.sh`，重新生成，把生成的 diff 一起提交。CI 每次重跑生成并
  `git diff --exit-code`，手改会当场红。
- 从上游 `milvus-io/milvus` 移植的文件要保留来源声明头（Apache-2.0 §4(a)(b)
  的要求）。上游同步是**手动评估、不自动合并**，流程见 `AGENTS.md`。

连真实 Milvus 跑集成测试的步骤见
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。

## 来源与许可

本项目是 [milvus-io/milvus](https://github.com/milvus-io/milvus) 的 Go SDK（`client/`，
Apache-2.0，Copyright (c) LF AI & Data Foundation）向 MoonBit 的移植/改写。
协议定义取自独立的 [milvus-io/milvus-proto](https://github.com/milvus-io/milvus-proto)
仓库，快照与锚定 commit 见 `proto/upstream/PROVENANCE.md`。

| 项 | 值 |
|---|---|
| 上游仓库 | `milvus-io/milvus`，`client/` 目录 |
| 基线 commit | `1bcc8cb1`（2026-09-30） |
| 上游许可 | Apache-2.0 |
| 上游版权 | Copyright (c) LF AI & Data Foundation |
| 本项目许可 | Apache-2.0（见 [`LICENSE`](./LICENSE)） |

关于「改写」的定性：Go → MoonBit 是重新实现而非逐行翻译，但**不是 clean-room**。
API 名称、字段名、协议常量值（如 `FieldType = 101`）、Option 构造函数名与默认值
均沿用上游，这些正是 Apache-2.0 覆盖的贡献物。归属说明就是本节，加上每个移植文件
顶部的来源声明头。

上游同步策略（手动评估、不自动合并）与基线 commit 变更时要动哪些文件，
见 [`AGENTS.md`](./AGENTS.md) 与
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。
