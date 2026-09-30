# Tangbuting/milvus-client

MoonBit client for [Milvus](https://milvus.io/) vector database.

## 包结构

| 包 | 内容 |
|---|---|
| `entity` | Schema / Field / Vector 抽象，含 BF16 手写转换（#12） |
| `index` | 索引参数 builder、`MetricType` / `IndexType` 枚举、索引 RPC 入参与响应解析（#16） |
| `proto` | 上游 `.proto` 快照、代码生成与可行性结论，见 `proto/REPORT.md`（#5 / #10） |
| `errors` | Milvus `common.Status` → MoonBit 错误模型（#13） |
| `transport` | 配置、metadata 组装、gRPC status —— 跨 target（#11） |
| `transport/native` | 真连 socket 的 Channel 实现 —— native 专属（#11） |

## 当前状态

传输层（Issue #11）已打通：能对真实 Milvus 建立 gRPC channel、
注入认证与 dbName、按超时控制调用。业务 RPC（collection / search / insert 等）
尚未实现，见 #5 的规划。

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
moon run cmd/main -- 127.0.0.1:19530 root:Milvus default
```

## 开发

```sh
moon check --target all && moon test --target all
```

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
