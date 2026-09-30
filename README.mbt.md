# Tangbuting/milvus-client

A community-driven MoonBit client for the [Milvus](https://milvus.io/) vector database.

> 本项目是社区驱动的 Milvus 客户端，**不是** Milvus 官方 SDK。"Milvus" 是 LF Projects, LLC
> 的商标；Apache-2.0 不授予商标权，包名中的 "milvus" 仅为指明兼容对象的描述性使用。
> 来源与改写定性见「来源与许可」一节。

## 包结构

单模块，下面每一行都是 `Tangbuting/milvus-client` 这个模块里的包。

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

## 能力边界

覆盖的是一条完整读写链路：集合生命周期、数据面（insert / upsert / delete）、
检索面（search / query）、分区与加载 / 刷盘、大结果集翻页（两个迭代器）。
更细的覆盖范围（各包支持哪些列类型、哪些枚举、哪些边界）在下面的分节里。

**只交付 column-based 一路**：写入用 `WriteColumn` 承接 `@column.ColumnValue`，
回读用 `@column.Column`。row-based API 尚未纳入，在
[`ROADMAP.mbt.md`](./ROADMAP.mbt.md) 里排期。

`CreateCollection` 不会顺带建索引或 load 集合 —— 上游 `IsFast()` 那条路是
「一步到位」的便利，本移植把它拆成显式调用。**顺序不能倒**：
`create_collection` → `create_index` → `load_collection`（轮询到 `Loaded`）
→ `search` / `query`。Milvus 拒绝加载没有索引的集合，也拒绝对未加载的集合检索；
加载是异步的，`load_collection` 返回不代表就绪。

## 安装

要求 MoonBit 工具链 **0.10.14 或更高**（`moon version --all` 查看）：

```sh
moon add Tangbuting/milvus-client
```

包名是 `Tangbuting/milvus-client`，版本随 `moon.mod` 走；`moon add` 会把当前
版本写进依赖清单。

本模块没有别的非 registry 依赖：协议代码就是本模块自己的包目录，
不存在「装上了但依赖没上 registry」的情况。

### 从源码使用

本仓库**只有一个模块**，生成物也已入库，所以签出后直接就能构建：

```sh
moon check --target all && moon test --target all
```

改了 `proto/trimmed/*.proto` 才需要重新生成（需 `protoc`）：

```sh
proto/tools/gen.sh trimmed
```

### 模块布局

没有第二个模块。协议代码是**本模块的普通包目录** `proto/milvus/proto/`，
与 `errors` / `client` 同级：

```text
Tangbuting/milvus-client/proto/milvus/proto/{common,milvus,msg,schema}
```

`protoc-gen-mbt` 生成时只会写「自己那个模块」的 import 路径
（`Tangbuting/proto/...`），所以 `gen.sh` 在生成后统一改写成主模块名下的路径。
四个 wire 往返测试包（`p0test` / `indextest` / `rpctest` / `lifecycletest`）
也是 `gen.sh` 从 `proto/tools/*/` 叠加进去的，和协议包同级。

这么摆的理由：发布包必须自带被依赖的协议代码。早先的布局是
「生成物不入库 + `moon.work` 注册成第二个模块」，本地面板能跑，
但 `moon package` 打出来的 zip 里带着一份指向 `proto/gen/trimmed/proto`
的 `moon.work`，而那个目录不在包里 —— 装的人一解析工作区就挂。
理由与试过的两条窄路记在 [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。

目标平台：模块 `preferred_target = "wasm"`，`client` / `entity` / `index` /
`column` / `errors` / `transport` 在 `wasm` / `wasm-gc` / `js` / `native` 四个
后端下都编得过；真连 socket 的 `client/native` + `transport/native` 是
native 专属，用它们要 `--target native`。

## 快速上手

从空目录到「写得进、检索得到、取得回」的最小闭环。把这里的例子按顺序拼起来
就能跑通；每一步的边界条件与可选项在后面的分节里。

### 1. 配连接与建客户端

传输层把「发字节」抽成一个 `Unary` 函数值：

```moonbit nocheck
///|
pub type Unary = async (String, Bytes) -> Bytes raise @transport.RpcError
```

所以同一份调用逻辑在 wasm / js 下也编得过，测试里给个假的就行，不必真连网络。
native 下用 `client/native` 接一条真连接：

```moonbit nocheck
let cfg = @transport.Config::new("127.0.0.1:19530")
  .with_token("root:Milvus")
  .with_db_name("default")
  .with_timeout_millis(5000)
let (client, channel) = @native.connect(cfg)
// ... 跑下面各步 ...
channel.close()
```

### 2. 声明 schema 并建集合

```moonbit nocheck
let schema = @entity.CollectionSchema::new([
  @entity.Field::new("id", @entity.DataType::Int64).as_primary_key().as_auto_id(),
  @entity.Field::new("title", @entity.DataType::VarChar).with_max_length(512),
  @entity.Field::new("vector", @entity.DataType::FloatVector).with_dim(768),
])
schema.validate() // 本地就挡下服务端会拒绝的 schema

client.create_collection(@client.new_create_collection_option("demo", schema))
```

不想手写 schema 就用便利构造，默认 id/vector + 动态字段：

```moonbit nocheck
client.create_collection(@client.simple_create_collection_option("demo", dim=768))
```

### 3. 写入

写入是列式的：一列一个 `WriteColumn`，列的行数必须一致，向量维度必须与列声明吻合。
本地先校验，这些在服务端只表现成「静默少写」。

```moonbit nocheck
let _ = client.insert(
  @client.new_write_option("demo", [
    @client.WriteColumn::new(
      "title",
      @column.ColumnValue::VarChar(["第一行", "第二行"]),
    ),
    @client.WriteColumn::new(
      "vector",
      @column.ColumnValue::FloatVector(768, [vec_a, vec_b]),
    ),
  ]),
)
```

`upsert` 共用同一个 `WriteOption`（`new_write_option`），多一个 `with_partial_update`
开关；`delete` 的 Option 是 `new_delete_option`。

### 4. 检索

```moonbit nocheck
let hits = client.search(
  @client.new_search_option("demo", 3, [
    @column.ColumnValue::FloatVector(768, [query_vector]),
  ])
  .with_anns_field("vector")
  .with_output_fields(["title"]),
)
for hit in hits.hits {
  let title = match hit.fields.get("title") {
    Some(@column.ColumnValue::VarChar(v)) => v[0]
    _ => ""
  }
  println("\{hit.score} \{title}")
}
```

`search` 只是这个例子的一个截面，`with_filter` 加标量过滤、`with_metric_type`
换距离度量、`with_offset` 翻页、`with_search_param` 补构建器没建模的键 ——
键集合与顺序照搬上游。

### 5. 查询

查询是**表达式 + 逐点列名**。`output_fields` 必须逐点写清楚，不要用 `["*"]`、
也不要留空：服务端在返回全部字段时不填 `FieldData.field_name`，列名会全空，
按名取列取不到、行数也会读成 0（症状酷似「过滤条件没生效、全量返回」）。

```moonbit nocheck
///|
let rows = client.query(
  @client.new_query_option("demo")
  .with_filter("title in [\"第一行\",\"第二行\"]")
  .with_output_fields(["id", "title"])
  .with_limit(100),
)

///|
let title_column = rows.column("title") // Some(@column.Column)，按名取列

///|
let first = match title_column {
  Some(col) => col.get_as_string(0) catch { _ => "" }
  None => ""
}
```

`limit` 不预置，不传就是服务端默认上限；想断言确定行数必须显式 `with_limit`。
`@column.Column` 按列类型取值（`get_as_int64` / `get_as_json_string` / …），
读错类型报 `ColumnError`，**不做隐式转换**。

### 6. 起索引、加载、翻页

检索前的硬要求，以及超大结果集的两条翻页路径：

```moonbit nocheck
// 起索引（HNSW 默认 M=16、efConstruction=200，与上游一致）
let index = @index.new_hnsw_index(@index.MetricType::COSINE, m=32)
client.create_index(@client.new_create_index_option("demo", "vector", index))

// 加载：先发请求，再等进度到 100%
client.load_collection(@client.new_load_collection_option("demo")).wait()

// 查询迭代器：客户端侧主键游标，翻到末尾报 EndOfIterator 而不是故障
let iterator = client.query_iterator(
  @client.new_query_iterator_option("demo")
  .with_filter("title != \"\"")
  .with_output_fields(["title"])
  .with_batch_size(500),
) catch {
  _ => return
}
while true {
  let page = iterator.next() catch {
    err => if err.is_end_of_iterator() { break } else { return }
  }
  ignore(page.len())
}
iterator.close()
```

`SearchIterator` 是服务端侧 v2 游标，接口同形（`new_search_iterator_option` /
`next` / `close`），`nq` 恒为 1。

### 7. 分区与刷盘

```moonbit nocheck
client.create_partition(@client.new_create_partition_option("demo", "p1"))
client.load_partitions(@client.new_load_partitions_option("demo", ["p1"])).wait()
client.flush(@client.new_flush_option("demo")).wait()
client.release_collection(@client.new_release_collection_option("demo"))
```

`LoadTask::wait` / `FlushTask::wait` 与上游 `Await` 一致，**先等一个间隔再查
第一次**，间隔默认 200ms（`with_check_interval_millis` 可调）。

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

与上游的同步策略是**手动评估、不自动合并**，流程与理由见
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。基线 commit 变更时，需同步更新
本节、`proto/upstream/PROVENANCE.md` 与 `AGENTS.md`。

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

`cmd/main` 失败时以非 0 退出码结束（与 `cmd/integration` 同样的 `abort` 写法），
CI 直接看退出码。建连失败、Health/Check 报了非超时的错误都算失败；
「调用超时」反过来算通过 —— 那正是它要验的最后一条标准。

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

### 分区与数据生命周期

分区是集合内的写入分组；加载（load）把数据放进查询节点后检索才看得到。
两者与 flush 都在 `@client.Client` 上，用法与上游 Go SDK 对齐：

```moonbit nocheck
///|
async fn lifecycle(client : @client.Client) -> Unit raise @client.ClientError {
  // 建分区、写入时可以带上它
  client.create_partition(@client.new_create_partition_option("demo", "p1"))

  // 加载集合：先发 LoadCollection，再等进度到 100
  let load = client.load_collection(@client.new_load_collection_option("demo"))
  load.wait()

  // 只加载某个分区
  let part = client.load_partitions(
    @client.new_load_partitions_option("demo", ["p1"]).with_replica(2),
  )
  part.wait()

  // 不等待时看状态：Loading 时 progress 有意义
  let state = client.get_load_state(@client.new_get_load_state_option("demo"))

  // 刷盘：Flush 触发，wait 轮询 GetFlushState 到落盘
  let flush = client.flush(@client.new_flush_option("demo"))
  flush.wait()

  // 卸载后检索会报错，这是「明确不可查」的判据
  client.release_collection(@client.new_release_collection_option("demo"))
}
```

要点：

- `LoadTask::wait` / `FlushTask::wait` 与上游 `Await` 一致，**先等一个间隔
  再查第一次**；间隔默认 200ms，可用 `with_check_interval_millis` 调。
  取消（`@async` 取消）会翻成 `Code::Cancelled` 的 `Transport` 错误。
- `LoadTask` 只等它对应的那部分：`load_collection` 的等整个集合，
  `load_partitions` 的只等那几个分区。
- `refresh` 模式下等的是 `refresh_progress` 而不是 `progress`
  （`with_refresh()` 打开），与上游 `LoadTask` 的 `refresh` 开关一致。
- `has_partition` 走真 `HasPartition` RPC（返回 `BoolResponse`），
  这点与 `has_collection`（走 `DescribeCollection`）不同，前者是上游的选择。
- `list_partitions` 走 `ShowPartitions` 且 `type = All`，含默认分区 `_default`。
- `get_load_state` 返回 `LoadState`：`state` 是 `CollectionLoadState`
  （`NotExist` / `NotLoad` / `Loading` / `Loaded` / `Unknown(n)`），
  `progress` 只在 `Loading` 时有意义。`Unknown(n)` 保留原始序号，
  别并进 `NotLoad`——那会把「没见过的状态」当成「还没开始」。
- `FlushTask` 里的 `segment_ids` / `flush_timestamp` 就是 `GetFlushState` 的入参，
  单独查时用 `get_flush_state`。

## 迭代器

Milvus 服务端对单次返回有上限，超过就得翻页。两条路，选一条：

```moonbit nocheck
///|
async fn demo(client : @client.Client) -> Unit {
  // 查询迭代器：客户端侧主键游标，不依赖服务端版本
  let iterator = client.query_iterator(
    @client.new_query_iterator_option("demo")
    .with_filter("age > 18")
    .with_output_fields(["name"])
    .with_batch_size(500),
  ) catch {
    _ => return
  }
  while true {
    let page = iterator.next() catch {
      err => if err.is_end_of_iterator() { break } else { return }
    }
    // page : @client.QueryResult，与 Client::query 的返回同形
    ignore(page.len())
  }
  iterator.close()
}

///|
async fn demo_search(client : @client.Client) -> Unit {
  // 检索迭代器：服务端侧 v2 游标，nq 恒为 1
  let iterator = client.search_iterator(
    @client.new_search_iterator_option("demo", 1000, [
      @column.ColumnValue::FloatVector(768, [[0.1, 0.2]]),
    ])
    .with_anns_field("vector")
    .with_batch_size(500),
  ) catch {
    _ => return
  }
  let hits = iterator.next() catch { _ => return }
  ignore(hits.hits.length())
  let _ = iterator.close()
}
```

要点：

- 走到末尾报 `IteratorError::EndOfIterator`，不是故障。`is_end_of_iterator`
  用来把它从 `while` 里放出来；`IteratorError::Closed` 才是「迭代器已经关了」。
- `close` 之后、或翻完之后再问，一律报 `EndOfIterator` / `Closed`，
  不会又发一发请求。
- `SearchIterator::close` 会**真的**发一次空检索把服务端会话收掉
  （服务端侧游标不会自己过期）；翻到末尾时也自动收一次。返回值告诉你
  服务端侧关成没关成，失败不往上抛 —— 调用方多半是在 `defer` 里关的。
- `QueryIterator` 在服务端没有会话，`close` 只是个本地标记。
- `with_limit` 是整体上限：只决定「还发不发下一次请求」，**不跨批截断**。
  上游的 `SearchIterator` 会切短超出上限的那一批，本移植统一不切。
- `QueryIterator` 要求主键是 `Int64` 或 `VarChar`（表达式得能排序），
  否则在建立迭代器时就报 `Setup`，而不是翻出一个错序的结果。
- `SearchIterator` 的 `nq` 必须为 1，多给会报 `Setup`。

## 已知限制

- 传输失败与「服务端拒绝」是两个不同的 `ClientError` 分支：
  `Transport` 可以原样重试，`Server` 要看错误码。`is_transport_failure` /
  `is_client_error_retryable` 用来分流。
- 不缓存集合 schema，所以 insert / upsert 不带 `schema_timestamp`，
  也没有上游那套 schema-mismatch 自动重试。schema 变更后由调用方重新描述集合。
- `WriteColumn` 不支持 `Array` 列：元素的 `DataType` 没法从值本身推出来，
  要写数组字段得先补一个带元素类型的列类型。
- Binary / Int8 向量列在 `@column.ColumnValue` 里是「逐行一块字节」，
  行内字节数按 `dim`（binary 按 `dim / 8`）校验。
- 迭代器不做跨批截断（见「迭代器」一节）：`with_limit(10)` 配
  `with_batch_size(100)` 时你一次拿到 100 行，而不是 10 行。
- `SearchIterator` 依赖服务端实现 SearchIterator V2。老服务端不给
  `search_iterator_v2_results`，`next` 会报 `Setup`（上游这里是
  `ErrServerVersionIncompatible`）。
- 未覆盖的能力见 [`ROADMAP.mbt.md`](./ROADMAP.mbt.md)。

## 开发

构建与测试、连真实 Milvus 跑集成测试、生成 proto 代码，见
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。

协作约定与各包的实现约束见 [`AGENTS.md`](./AGENTS.md)；还没做、打算做的事
见 [`ROADMAP.mbt.md`](./ROADMAP.mbt.md)。
