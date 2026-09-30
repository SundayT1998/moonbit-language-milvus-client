# 路线图

这份文档放**已经列进规划、但还没做**的事。README 只讲今天能用的东西；
「暂时没做」和「不打算做」是两回事，前者在这里有位置。

排序不代表承诺时间，但代表依赖顺序：上面的做完，下面的才有意义。

## 1. row-based API

上游 Go SDK 有两条写入/检索路径：column-based 与 row-based。本移植目前
只覆盖 column-based 一路。

row-based 进规划，不是「不移植」。「不移植」意味着这个能力永远不会有，
但它的价值很明确：

- 调用方手里是**结构化的行**（每行一个 `Map[String, Value]` / 接口体），
  而不是按列拼好的数组时，row-based 是唯一顺手的入口；
- 动态字段（JSON）场景下，行的形状是运行时才知道的，编译期很难按列展开；
- 与上游对齐的完整度：两份 API 都在，从 Go SDK 迁过来的人不用改调用形状。

预期形态对齐上游 `client/milvusclient`：

- `Client::insert_rows` / `upsert_rows` / `delete_rows`；
- 行 → `FieldData` 的编解码走 schema 推导（列名、`DataType`、`dim` / `max_length`）；
- 与 `WriteColumn` 共用同一套本地校验（行数一致、dim 吻合、空值处置）。

前置条件：更完整的 schema 缓存。当前不缓存 schema，所以 insert 不带
`schema_timestamp`，也没有 schema-mismatch 自动重试（见 README「已知限制」）。
row-based 的行 → 列推导同样需要这份 schema，所以先补缓存，再谈 row-based。

## 2. schema 缓存与 mismatch 自动重试

对齐上游 `client/milvusclient` 的 schema 缓存：`DescribeCollection` 结果按集合名
缓存，`schema_timestamp` 带进写请求；服务端报 mismatch 时刷新缓存重试一次。

这是 row-based 的前置条件，也是「写请求多一次 RPC 往返」的解法。

## 3. Binary / Int8 向量的 Array 列

`WriteColumn` 目前不支持 `Array` 列 —— 元素的 `DataType` 推不出来。
补一个带元素类型的列构造器即可，不用等别的。

## 4. 更多一致性等级与检索参数

- `ConsistencyLevel` 现有的档位之外，按上游补齐；
- `search_params` 里 `params` 子表的其余键（如 `level`、`radius`）按需建模。

## 已完成

已交付的能力清单在 README 的「能力边界」一节 —— 那份清单跟着 API 走，
不跟着任务走，所以放在 README 而不是这里。
