# Tangbuting/milvus-client

A community-driven MoonBit client for the [Milvus](https://milvus.io/) vector database.

> 本项目是社区驱动的 Milvus 客户端，**不是** Milvus 官方 SDK。"Milvus" 是 LF Projects, LLC
> 的商标；Apache-2.0 不授予商标权，包名中的 "milvus" 仅为指明兼容对象的描述性使用。
> 来源、改写定性与同步策略见下节「来源与许可」。

## 包结构

| 包 | 内容 |
|---|---|
| `entity` | Schema / Field / Vector 抽象，含 BF16 手写转换（#12） |
| `index` | 索引参数 builder、`MetricType` / `IndexType` 枚举、索引 RPC 入参与响应解析（#16） |
| `column` | 响应 `FieldData` → 列容器反序列化，查询/检索回读的落点（#14） |
| `proto` | 上游 `.proto` 快照、代码生成与可行性结论，见 `proto/REPORT.md`（#5 / #10） |
| `errors` | Milvus `common.Status` → MoonBit 错误模型（#13） |
| `transport` | 配置、metadata 组装、gRPC status —— 跨 target（#11） |
| `transport/native` | 真连 socket 的 Channel 实现 —— native 专属（#11） |
| `client` | Client 门面与核心 RPC 编排：collection / insert / upsert / delete / search / query（#15） |
| `client/native` | 把 `client` 的 unary 调用接到真实连接上 —— native 专属（#15） |

## 当前状态

客户端门面（Issue #15）已交付：集合生命周期（创建 / 描述 / 是否存在 / 列出 / 删除）、
数据面（insert / upsert / delete）、检索面（search / query）都走通了，
Option 构造函数名与默认值对齐上游。

**只保留 column-based 一路**，row-based API 不移植（风险 R2）。
`CreateCollection` 也不会顺带建索引或 load 集合 —— 上游 `IsFast()` 那条路属于后续 Issue。

上层调用只要给一个 `Unary` 函数值就能跑，所以测试与 wasm 下不需要真连接：

```moonbit nocheck
///|
let client = @milvus_client.new_client(cfg, my_unary)
```

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

### 同步策略

上游 `client/` 是持续演进的活跃代码，本移植是它在一个时间点上的快照。
同步策略是**手动评估、不自动合并**：

1. 定期（或按需）比对上游 `client/` 自基线 commit 以来的改动；
2. 对每处改动判断是否影响已移植的包（`entity` / `index` / `errors` / …）；
3. 受影响则在对应包内手动回移，并在 PR 中注明对齐的上游 commit；
4. 不跟随上游做「机械等价」的目录级同步——MoonBit 侧的分包与上游并非一一对应。

流程细节见 [`AGENTS.md`](./AGENTS.md)。基线 commit 变更时，需同步更新本节、
`proto/upstream/PROVENANCE.md` 与 `AGENTS.md`。

## entity

```moonbit nocheck
let schema = @entity.CollectionSchema::new([
  @entity.Field::new("id", @entity.DataType::Int64).as_primary_key().as_auto_id(),
  @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(512),
  @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(768),
])
schema.validate() // 本地就挡下服务端会拒绝的 schema
```

要点：

- `DataType` 的数值与 `schema.proto` 逐条对齐，`entity/datatype_test.mbt` 用断言锁住。
- `dim` / `max_length` 不是 `FieldSchema` 的字段，服务端从 `type_params` 里读，
  所以 `Field::type_params_pairs()` 负责把它们拼出来，`type_params` 留作其余条目的出口。
- BF16 转换是手写的（`bfloat16_from_float`），对 float32 做 bit 截断加
  round-half-to-even，行为与上游 `ml_dtypes.bfloat16` 一致，零依赖。
- 稀疏向量保留 `(indices, values)` 表示，wire 上是每项 4 字节 index + 4 字节 float32 的小端对。

## 列容器

`column` 把响应里的 `FieldData` 解成列，`Query` / `Search` 的回读都从这里过。

```moonbit nocheck
let col = @column.from_field_data(field_data, begin=0, end=-1)
for i = 0; i < col.len(); i = i + 1 {
  if col.is_null(i) {
    continue
  }
  // 按列类型取；读错类型会报 ColumnError，不做隐式转换
  let v = col.get_as_int64(i)
}
```

要点：

- 支持 Bool / Int8~Int64 / Float / Double / String / VarChar / Text /
  Timestamptz / Geometry / JSON / Array，以及全部向量类型。
- 窄整数按位宽有符号收窄：服务端把 `Int8` 放在 `int32` 数组里，`0xFF` 读成 -1。
- 可空列两种布局都认：`valid_data` 与数据等长（行满）或等于有效数（紧凑）。
  两处有效性位图（旧的 `FieldData.valid_data` 与字段级的）都有且不一致时
  报错，不挑一边。
- 动态字段（JSON）以 **JSON 字符串**取回（`get_as_json_string`），不做路径查询，
  因此不引 `tidwall/gjson`。
- float16 / bfloat16 解码逐位对齐 IEEE-754，不是近似。

## 索引

`index` 包的参数 builder 与上游 Go SDK 的 `client/index` 对齐：
键名、默认值、枚举字面量逐条一致，非法组合在构造期报错而不是等一次 RPC 往返。

```moonbit nocheck
// HNSW：默认 M=16、efConstruction=200，与上游一致
let idx = @index.new_hnsw_index(@index.MetricType::COSINE, m=32)

// 拼出 CreateIndex 入参
let req = @index.CreateIndexRequest::from_index(
  "demo_collection",
  "embedding",
  idx.with_name("embedding_idx"),
)

// 补构建器未建模的参数
let extra = @index.IndexParams::new()
extra.set("refine", "true")
let idx2 = @index.new_hnsw_index(@index.MetricType::L2).with_extra_params(extra)
```

越界与非法组合在构造期被拦下：

```moonbit nocheck
let _ = @index.new_hnsw_index(@index.MetricType::L2, m=1)
// raise IndexParamError::OutOfRange(key="M", value=1, expected=">= 2")
```

## 传输层

```
transport/          配置、metadata 组装、gRPC status —— 跨 target（wasm / wasm-gc / js / native）
transport/native/   真连 socket 的 Channel 实现 —— native 专属
```

为什么要拆开：传输实现依赖 `moonbitstack/moonrpc/net`，
而它自己声明了 `supported_targets = "native"`。
模块的 `preferred_target = "wasm"` 与之冲突，
混在一个包里会让 wasm / js 直接编不过。
拆开后，wasm 下拿到的是可用的配置与错误类型，缺的只是「谁来发字节」。

详见下面「已知限制」一节。

### 用法

```moonbit nocheck
// 配置（跨 target）

///|
let cfg = @milvus_client.with_address("127.0.0.1:19530")
  |> @milvus_client.with_token("root:Milvus")
  |> @milvus_client.with_db_name("default")
  |> @milvus_client.with_timeout_millis(5000)
```

native 下发起调用：

```moonbit nocheck
///|
async fn demo() -> Unit raise @transport.RpcError {
  let cfg = @transport.Config::new("127.0.0.1:19530")
    .with_token("root:Milvus")
    .with_db_name("default")
    .with_timeout_millis(5000)
  let client = @native.Client::connect(cfg)
  let reply = client.unary(
    "/milvus.proto.milvus.MilvusService/DescribeCollection", body,
  )
  client.close()
  ignore(reply)
}
```

判断失败是不是超时：

```moonbit nocheck
match ... {
  // ...
} catch {
  err => if err.is_deadline_exceeded() { /* 超时 */ }
}
```

自检程序（连上后发一次 Health/Check）：

```sh
moon run --target native cmd/main -- 127.0.0.1:19530 root:Milvus default
```

## 客户端

`client` 是薄客户端：Option → protobuf 请求 → 发 RPC → 响应反序列化，
本地不做任何向量计算。发字节这件事被抽成 `Unary` 函数值，
所以同一份调用逻辑在 wasm / js 下也编得过。

```moonbit nocheck
///|
async fn demo(client : @client.Client) -> Unit raise @client.ClientError {
  // 建集合：给名字和维度就够，默认 id/vector + 动态字段
  client.create_collection(
    @client.simple_create_collection_option("demo", dim=768),
  )

  // 写入
  let _ = client.insert(
    @client.new_write_option("demo", [
      @client.WriteColumn::new("id", @column.ColumnValue::Int64([1L, 2L])),
      @client.WriteColumn::new(
        "vector",
        @column.ColumnValue::FloatVector(2, [[0.1, 0.2], [0.3, 0.4]]),
      ),
    ]),
  )

  // 检索
  let hits = client.search(
    @client.new_search_option("demo", limit=3, [
      @column.ColumnValue::FloatVector(2, [[0.1, 0.2]]),
    ]).with_anns_field("vector"),
  )
}
```

native 下接一条真连接（`client/native`）：

```moonbit nocheck
let (client, channel) = @native.connect(cfg)
// ... 跑上面的调用 ...
channel.close()
```

要点：

- `MutationResult.ids` 只在服务端回主键时是 `Some`（insert / upsert 有，delete 没有）。
- 写入前本地校验：列行数必须一致、向量 dim 必须与列声明吻合、空列直接拒。
  这些在服务端只会表现成「静默少写」，早点失败更好查。
- `search_params` 固定写全 `anns_field` / `topk` / `offset` / `metric_type` /
  `round_decimal` / `ignore_growing` / `params` 七个键，调用方的
  `with_search_param` 最后覆盖 —— 与上游的键集合和顺序一致。
- `has_collection` 走 `DescribeCollection`，把 `CollectionNotExists` 当 `false`
  而不是失败，与上游一致。
- 未显式设一致性等级时，请求里 `use_default_consistency` 为真、等级填 `Bounded`，
  由服务端决定最终档位。

## 已知限制

- 传输失败与「服务端拒绝」是两个不同的 `ClientError` 分支：
  `Transport` 可以原样重试，`Server` 要看错误码。`is_transport_failure` /
  `is_client_error_retryable` 用来分流。
- 不缓存集合 schema，所以 insert / upsert 不带 `schema_timestamp`，
  也没有上游那套 schema-mismatch 自动重试。schema 变更后由调用方重新描述集合。
- `WriteColumn` 不支持 `Array` 列：元素的 `DataType` 没法从值本身推出来，
  要写数组字段得等后续 Issue 补一个带元素类型的列类型。
- Binary / Int8 向量列在 `@column.ColumnValue` 里是「逐行一块字节」，
  行内字节数按 `dim`（binary 按 `dim / 8`）校验。

## 开发

```sh
moon check --target all && moon test --target all
```

### 连真实 Milvus 跑集成测试

单测用假传输跑，不碰网络；要验「协议编排在真服务端上成立」，用容器起一个
官方 Milvus，再跑 `cmd/integration`：

```sh
scripts/milvus-start.sh          # 起 milvusdb/milvus:v3.0.2 的 standalone 容器
moon run --target native cmd/integration -- 127.0.0.1:19530
scripts/milvus-stop.sh           # 停掉并删除容器
```

`cmd/integration` 走完整门面：建集合 → 写入 10 行 → 建索引 → 加载集合 →
检索（最近邻应当是自己）→ 按表达式查询 → 删集合，任一步不符就非 0 退出。
CI 里同样三步一循环，收尾放在「成功失败都执行」的位置，容器不会漏在 runner 上。
参数（镜像 / 容器名 / 端口 / 等待秒数）都能用环境变量覆盖，
`scripts/milvus-start.sh` 头部有清单。

这里的前三步顺序是 Milvus 的硬要求，写检索流程时照抄：

```text
create_collection → create_index → load_collection →（轮询到 Loaded）→ search / query
```

- 不建索引就 `load_collection`：服务端回 `index not found`。
- 建了索引不 `load_collection` 就检索：服务端回 `collection not loaded`。
- `load_collection` 返回只代表请求被受理，数据面就绪是异步的，所以要轮询
  `get_load_state` 到 `Loaded`，直接接着检索会偶发失败。
- `Query` 没显式给 `limit` 时，客户端会补上默认的 16384。别指望「不发 limit
  就是不限量」—— Milvus 对没带 `limit` 的 Query 反而会全量返回。

自检用 `new_flat_index(L2)`：10 行的集合上暴力检索就是最优解，也不用等索引构建。

embedded etcd 的配置文件用 `docker cp` 送进容器（`create` → `cp` → `start`），
不挂单文件卷：CI 的 docker daemon 跑在 dind 容器里，看不到本任务 `/tmp` 下的文件，
挂载源不可达时 docker 会把目标路径建成空目录，Milvus 读到目录会直接 segfault。
写新脚本时按同样方式处理配置文件。

生成 proto 代码（需 `protoc`）：

```sh
proto/tools/gen.sh trimmed   # P0 + 索引 RPC 的裁剪集
```

生成物在 `proto/gen/`，不入版本库；也不要手改，改动请在 `.proto` 或 `gen.sh` 里做。
签出后先跑一次生成，`proto/gen/` 不在版本库里，否则 `errors` 包找不到
`Tangbuting/proto/milvus/proto/common`：

```sh
proto/tools/gen.sh trimmed                 # 生成 P0 裁剪集
moon work init . proto/gen/trimmed/proto   # 把生成模块注册进工作区
```
