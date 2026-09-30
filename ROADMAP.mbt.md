# Roadmap

本文件记**还没做、且打算做**的事。已完成的能力清单在
[`README.mbt.md`](./README.mbt.md) 的「能力边界」，过程与归档在
[`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)。

排期不是承诺，顺序按「解锁别人的能力」排：越靠前越是后面几项的前置。

## P1 — row-based API

上游 `client/milvusclient` 同时提供 row-based 与 column-based 两路 API。
本项目 P0 只交付了 **column-based 一路**（写入走 `WriteColumn`，回读走
`column.Column`），row-based 那一路 —— 整行值进出的写法、以及
`CreateCollection` 的 `IsFast()` 快捷路径 —— 尚未纳入。
动手前先照基线 commit 逐条核对上游的 API 形状，别照名猜。

**为什么放在规划里而不是写成「不移植」**：row-based 解决的是另一类调用习惯 ——
调用方手上是「一行一个键值对」的数据，不想自己先拆成列。这在「从 JSON /
表格读进来直接写」的场景里省事，不是 column-based 的重复品。本项目要先补的
不是 API 表面，而是两件底层的东西（见下），补完它才是低成本的。

### 前置：动态字段与 JSON 列

row-based 的键是运行时字符串，落到 schema 上就是动态字段（`$meta` / JSON）。
现在 `column` 包只把动态字段以 JSON 字符串取回，不做任何路径查询，
写侧也没有对应的入口。row-based 要成立，得先有：

- 写入侧的动态字段通道（现在 `WriteColumn` 推导不出 `Array` 的元素类型，
  动态字段更是连列都没有）；
- 与现有 `get_as_json_string` 配套的取字段方式。

### 前置：主键与字段名的类型往返

行里的值要能按 schema 转回 proto 的 `FieldData`，需要一张
`entity.DataType` → 值类型 → proto 的完整对照表。现在这张表只覆盖
`WriteColumn` 支持的那几支。

### 交付形态（待定）

三处需要定，先记下来，动手前先在这里把结论写清楚：

- **是否要 `IsFast()` 快捷路径**。上游 `CreateCollection` 的 `IsFast()` 会
  顺带建索引并 load。本项目刻意把这三步拆开（见 README「能力边界」），
  row-based 若要带这个开关，是回到「一步到位」还是同样拆开，要先定。
- **一行的值类型**。是复用 `column.ColumnValue`（让回读的 `Column` 改个名字
  写回去），还是另造一个更贴近动态语言的枚举。倾向前者，但 `Array` 列的元素
  类型推导问题会跟着一起过来。
- **与 column-based 的关系**。两路 API 应当共用同一套请求编排（`client` 包
  里 `call_service` 那条私有的路），只是入口的形状不同；不要为 row-based
  复制一份编排逻辑。

## P2 — 一致性等级与 schema 缓存

- **schema 缓存**：现在不缓存集合 schema，insert / upsert 的 `schema_timestamp`
  留 0，也没有上游那套 schema-mismatch 自动重试。要做就得连缓存一起补，
  否则重试没有依据。这是 README「已知限制」里明写的一条。
- **一致性等级**：`with_consistency_level` 已能透传，但缺少上游那种按场景
  推默认档位的便利层。

## P3 — 更多索引类型与自定义传输

- 索引 builder 目前覆盖上游最常用的几支；IVF 系列的部分调参项、
  `GPU_*` 等尚未建模，未建模的参数走 `IndexParams::set` 兜底。
- `Unary` 已经是可替换的函数值（见 README「传输层」），但还没有
  HTTP / 自定义协议的参考实现；这是给上层「不想引 gRPC」的场景留的口子。

## 不做

- **自动跟随上游合并**。上游 `client/` 是活跃代码，本移植是快照，
  同步走「手动评估」流程（见 [`docs/DEVELOPMENT.md`](./docs/DEVELOPMENT.md)）。
- **把本项目表述成官方 Milvus SDK**。归属措辞是
  "community-driven MoonBit client for Milvus"，见 README「来源与许可」。
