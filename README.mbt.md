# Tangbuting/milvus-client

MoonBit client for [Milvus](https://milvus.io/) vector database.

## 进度

| 包 | 状态 |
|---|---|
| `entity` | Schema / Field / Vector 抽象，含 BF16 手写转换（#12） |
| `proto` | `milvus-proto` 生成结论见 `proto/REPORT.md`（#5） |

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

## 开发

```sh
moon check --target all && moon test --target all
```
