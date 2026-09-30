# Tangbuting/milvus-client

A community-driven MoonBit client for the [Milvus](https://milvus.io/) vector database.

> 本项目是社区驱动的 Milvus 客户端，**不是** Milvus 官方 SDK。"Milvus" 是 LF Projects, LLC
> 的商标；Apache-2.0 不授予商标权，包名中的 "milvus" 仅为指明兼容对象的描述性使用。
> 详见 [`NOTICE`](./NOTICE)。

## 包结构

| 包 | 内容 |
|---|---|
| `entity` | Schema / Field / Vector 抽象，含 BF16 手写转换（#12） |
| `index` | 索引参数 builder、`MetricType` / `IndexType` 枚举、索引 RPC 入参与响应解析（#16） |
| `proto` | 上游 `.proto` 快照、代码生成与可行性结论，见 `proto/REPORT.md`（#5 / #10） |
| `errors` | Milvus `common.Status` → MoonBit 错误模型（#13） |

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
| 来源与改写声明 | [`NOTICE`](./NOTICE) |

关于「改写」的定性：Go → MoonBit 是重新实现而非逐行翻译，但**不是 clean-room**。
API 名称、字段名、协议常量值（如 `FieldType = 101`）、Option 构造函数名与默认值
均沿用上游，这些正是 Apache-2.0 覆盖的贡献物。每个移植文件的来源声明头、
`NOTICE` 与本节共同构成完整的归属说明。

### 同步策略

上游 `client/` 是持续演进的活跃代码，本移植是它在一个时间点上的快照。
同步策略是**手动评估、不自动合并**：

1. 定期（或按需）比对上游 `client/` 自基线 commit 以来的改动；
2. 对每处改动判断是否影响已移植的包（`entity` / `index` / `errors` / …）；
3. 受影响则在对应包内手动回移，并在 PR 中注明对齐的上游 commit；
4. 不跟随上游做「机械等价」的目录级同步——MoonBit 侧的分包与上游并非一一对应。

流程细节见 [`AGENTS.md`](./AGENTS.md)。基线 commit 变更时，需同步更新本节、
`NOTICE`、`proto/upstream/PROVENANCE.md` 与 `AGENTS.md`。

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

## 开发

```sh
moon check --target all && moon test --target all
```

生成 proto 代码（需 `protoc`）：

```sh
proto/tools/gen.sh trimmed   # P0 + 索引 RPC 的裁剪集
```

生成物在 `proto/gen/`，不入版本库；也不要手改，改动请在 `.proto` 或 `gen.sh` 里做。
