# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

## 传输层分层（`transport/`）

- `transport/` 只放跨 target 的东西：配置、metadata 组装、gRPC status。
  模块 `preferred_target = "wasm"`，这层在 wasm / wasm-gc / js / native 下
  都必须编得过，所以**不要**在这里 import `moonbitstack/moonrpc/net`
  或任何 native-only 的包。
- `transport/native/` 放真连 socket 的实现，`moon.pkg` 里声明
  `supported_targets = "native"`。新开的 native-only 包照此办理。
- 根包 `milvus_client.mbt` 用 `pub type` + 转发函数暴露公共 API，
  不直接暴露 `@transport` 的内部结构。
- 细节与理由见 `README.mbt.md` 的「已知限制」。

## Development Environment

- CNB 云原生开发：在 `.cnb.yml` 的 `vscode` 事件中声明，与 CI 共用同一基础镜像
  `.cnb/Dockerfile`（基于 `cnbcool/default-dev-env`，MoonBit 工具链走中国站
  `cli.moonbitlang.cn`）。

## CI

- CNB 流水线：`.cnb.yml`，`push` / `pull_request` 跑两条 pipeline：
  - `check-and-test` —— `moon fmt`、`moon info`、`moon check --target all`、
    `moon test --target all`；
  - `integration` —— 起 Milvus 容器、跑 `cmd/integration`、收尾停容器。
- GitHub Actions：`.github/workflows/check.yml`（三平台 `build` + ubuntu 上的
  `integration`），`.github/workflows/publish.yml`（手动触发发布到 mooncakes.io）。
- 工具链下载源：CNB 侧统一 `cli.moonbitlang.cn`，GitHub 侧统一 `cli.moonbitlang.com`。
- 本地等价命令：`moon check --target all && moon test --target all`。

## 集成测试与 Milvus 容器（`scripts/`）

连真实服务端的那条链路：`scripts/milvus-start.sh` 起容器 →
`moon run --target native cmd/integration -- 127.0.0.1:19530` → `scripts/milvus-stop.sh` 收容器。

- 镜像锚定 **`docker.io/milvusdb/milvus:v3.0.2`**，容器参数照搬上游
  `milvus-io/milvus` 的 `scripts/standalone_embed.sh`：embedded etcd +
  `COMMON_STORAGETYPE=local`，一个容器自足。**不用 `latest`**，CI 要可复现。
  换版本时同步改 `.cnb.yml` 的 `MILVUS_IMAGE` 与本节。
- 就绪判据是容器内 `9091/healthz` 返回 200，而不是自己拨 19530 ——
  端口在数据面起来之前就监听了。
  **但判据要从宿主探，别读 docker 的 health 状态**：Moby 的重试一旦耗尽，
  `unhealthy` 是终态，后面服务真起来了也不会翻回 `healthy`。Milvus 冷启动
  在 CI 上耗时不定，固定 `start-period`/`retries` 迟早被穿破，一破就永久卡死
  （#33 的 CI 就是这么红了一整轮）。
- embedded etcd 的两份配置（`embedEtcd.yaml` / `user.yaml`）用 **`docker cp` 送进容器**，
  不要用 `-v` 挂单文件。CNB 的 `services: - docker` 是 dind，daemon 在另一个容器里，
  看不到本任务 `/tmp` 下的文件；挂载源在 daemon 侧不存在时，Docker 会在**目标路径建同名
  空目录**，于是 `/milvus/configs/embedEtcd.yaml` 变成目录。Milvus `v3.0.2` 的
  `InitEtcdServer` 在 `embed.ConfigFromFile` 失败时只记 `initError` 不返回，紧接着
  `cfg.Dir = dataDir` 解引用 nil 直接 SIGSEGV（`pkg/util/etcd/etcd_server.go:49`）——
  #33 的 CI 第一轮就是这么炸的。`docker cp` 走 daemon API 传 tar，跟 daemon 在不在
  同一文件系统无关。同理，别指望 `mktemp -d` 出的路径能被 daemon 挂进去。
- 容器配置顺序是 `create` → `cp` → `start`：Milvus 启动即读配置文件，先 `start`
  再 `cp` 会读到不存在的路径。落位后脚本会把文件 cp 回来比一次大小，配错时给明确原因，
  而不是甩一段 panic。
- CNB 侧收尾放 `endStages`（`stages` 成功失败都跑），GitHub 侧用 `if: always()`。
  stop 是幂等的，容器没起来时也只打个跳过。
- `cmd/integration` 是 native-only 的自检程序，与 `cmd/main`（只管传输层）分工：
  它走完整门面，验「建集合 → 写入 → 检索 → 查询 → 清理」在真服务端上成立，
  失败以非 0 退出码结束。
- **顺序是硬要求**：`create_collection` → `create_index` → `load_collection`
  （轮询到 `Loaded`）→ `search` / `query`。少一步的报错不同：没索引就 load
  是 `index not found`（`IndexNotExist`），建了不 load 就检索是
  `collection not loaded`（`CollectionNotLoaded`）。#33 的 CI 两种都踩过。
- 集成测试用 `new_flat_index(L2)`：10 行的集合上暴力检索就是最优解，
  也不用等索引构建。
- `Client::load_collection` 返回只表示请求被受理，数据面就绪是异步的，
  所以集成测试接着轮询 `Client::get_load_state` 到 `Loaded` 才检索。

## entity 包

`entity/` 放协议无关的领域类型（`DataType` / `Field` / `CollectionSchema` / 各向量类型），
不 import `proto/milvus/proto/`，也不碰 wire 编解码。数值常量（`DataType::to_int`）与
`milvus.proto.schema` 逐条对齐，改动等于改协议，必须同步改 `entity/datatype_test.mbt`。

BF16 是手写实现，对 float32 做 bit 截断加 round-half-to-even，与上游 `ml_dtypes.bfloat16`
逐位一致；不要为了省事换成有损的近似算法。改这个函数要跑 `entity/bfloat16_test.mbt`。

## 许可与上游同步

本项目是上游 Milvus Go SDK 的移植/改写，Apache-2.0 → Apache-2.0。

- 基线：`milvus-io/milvus` commit `1bcc8cb1`（2026-09-30），`client/`。
  `.proto` 来自 `milvus-io/milvus-proto`，锚定 commit 见 `proto/upstream/PROVENANCE.md`。
- 归属声明：来源仓库 + commit + 改写定性写明在 README「来源与许可」一节。
  归属相关事实变更时，同时更新这一节与 `proto/upstream/PROVENANCE.md`。
- 移植文件保留来源声明头：
  ```
  // 移植自 github.com/milvus-io/milvus client/<path> (Apache-2.0)
  // Copyright (c) LF AI & Data Foundation
  ```
  新增移植文件时必须带上；这是 Apache-2.0 §4(a)(b) 的要求，不是可选项。
- 商标：不得在文档里把本项目写成 official Milvus SDK。统一措辞是
  "community-driven MoonBit client for Milvus"。

### 上游变更 → 手动评估（风险 R6）

上游 `client/` 是活跃代码，本移植是快照。**不做自动同步**，流程是：

1. 比对上游 `client/` 自基线 commit 以来的改动；
2. 判断每处改动是否落在已移植的包里——**按语义判断，不按目录名机械对照**，
   MoonBit 侧分包与上游并非一一对应；
3. 受影响则在对应包内手动回移，PR 里注明对齐的上游 commit；
4. 需要推进基线时，同步更新 README「来源与许可」、
   `proto/upstream/PROVENANCE.md` 与本文件。

## 文档归属

- **README（`README.mbt.md`）面向使用者**，只写：项目定位、包结构、安装、
  怎么用、为什么这么设计、已知限制。
  不写进度、不写「尚未发布」、不写「某任务已交付」这类状态信息 —— 状态会过期，
  README 不该跟着烂。
  **用法集中在一个「快速上手」里**：把主要 API 串成一条可跑通的链路，不要为每个
  能力单开一节列 API；单点细节写进「各包说明」的要点列表。看的人要能一口气读完
  上手，而不是当 API 手册翻。
- **`ROADMAP.mbt.md` 放「还没做、打算做」**：能力缺口、前置条件、交付前要定的事。
  唯一的排期入口，别在别处维护第二份。
  **缺口不是「不移植」**——不打算做的事写进 ROADMAP 的「不做」一节并给理由，
  不要散落在 README 的「已知限制」里当一句免责声明。
- **`docs/DEVELOPMENT.md` 放过程**：开发流程（构建 / 集成测试 / 生成）、上游
  同步策略、交付范围、验收标准、发布流程、被推翻的方案与理由。任务分解与讨论
  现场在 Issue / PR 里，结论沉淀到这份文档或本文件。
- **Issue / PR 是对话现场，不是档案室**：讨论完把结论写进文档，不要往 Issue 里
  回贴长总结。单个 Issue 只留「问题是什么、怎么解」的短结论，够下一个接手的人
  看懂就行。
- 对外文档统一措辞是 "community-driven MoonBit client for Milvus"，
  别写成 official Milvus SDK（见「许可与上游同步」）。

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## Protobuf 生成代码（`proto/`）

`proto/` 下的 MoonBit 代码由 `protoc` + `moonbitlang/protoc-gen-mbt` **自动生成**，
**不要手工修改**。改了会在下次生成时被覆盖。

- `proto/upstream/` —— 上游 `milvus-io/milvus-proto` 的 `.proto` 只读快照，
  锚定 commit 见 `proto/upstream/PROVENANCE.md`。同样不手改。
- `proto/trimmed/` —— 裁剪到 P0 子集的 `.proto`。上游变更时需同步。
- `proto/milvus/proto/` —— 生成产物，**已入版本库**，是主模块里的普通包目录。
- `proto/tools/p0test/` —— 手写的 wire 往返测试模板，生成后由脚本叠加进产物。
- `proto/tools/gen.sh` —— 一键生成。`gen.sh upstream` 全量，`gen.sh trimmed` P0 集。
- `proto/REPORT.md` —— 生成器支持度探针报告（含已知缺陷与退路）。

要改生成结果，改 `.proto` 或 `gen.sh` 的参数，然后重新生成、把生成的 diff
一起提交。

### 单模块优先：没有第二个模块，也没有 moon.work

本仓库**只有一个模块**（`moon.mod` 那一份）。协议代码是它的普通包目录
`proto/milvus/proto/`，与 `errors` / `client` 同级，语法上是
`Tangbuting/milvus-client/proto/milvus/proto/<pkg>`。

发布包必须自带被依赖的协议代码。早先的写法是「生成物不入库 + 用 `moon.work`
把生成模块注册成第二个模块（`Tangbuting/proto`）」，本地面板能跑，但那个
`moon.work` 会跟着进发布 zip，里面的成员路径 `proto/gen/trimmed/proto`
在包里并不存在，装的人一解析工作区就挂；何况那个成员模块也不在 registry 上。
**别再引入第二个模块**，也别再加 `moon.work`。

生成后 `gen.sh` 做两件事把它接进主模块：

1. 把产物里的 import 前缀 `Tangbuting/proto/` 改写成
   `Tangbuting/milvus-client/proto/`（生成器只会写自己那个模块的路径）；
2. 从 `proto/tools/*/` 叠加四个 wire 往返测试包。

生成是**可复现**的：CI 每次重跑 `gen.sh` 后跟一句
`git diff --exit-code -- proto/milvus/proto`，有 diff 就红。所以手改生成物
一定会在 CI 上暴露，别手改。

`proto/upstream/` 与 `proto/trimmed/` 仍是**源码侧输入**，不参与编译；
只有 `proto/milvus/` 是编译目标。

## `column/` 包

Milvus 响应 `FieldData` → 列容器，对应上游 `client/column/`
（`milvus-io/milvus` commit `1bcc8cb1`，Apache-2.0）。

- `types.mbt` —— `ColumnValue` / `Column`，各列类型（含向量）
- `decode.mbt` —— `from_field_data`，`FieldData` → `Column` 的唯一入口
- `valid_data.mbt` —— 有效性位图的双源读取与行区间归一
- `extract.mbt` / `arrays.mbt` / `vectors.mbt` —— 从生成的 proto 里取数
- `float16.mbt` —— 回读侧的 fp16/bf16 解码（写侧在 `entity/`）
- `access.mbt` / `get_as.mbt` —— 行访问接口

约定：
- 读错类型报 `ColumnError::DataTypeNotMatch`，null 行报 `NullValue`，
  **不做隐式转换**。
- 动态字段（JSON）以 JSON 字符串取回，不做路径查询（不引 `tidwall/gjson`）。
- 生成的 `@schema.DataType` 与 `@entity.DataType` 的对应写在
  `column/datatype.mbt`；新增类型时两边都要动，`from_field_data` 的
  `match` 会提醒你漏了哪一支。

## `errors/` 包

Milvus `common.Status` → MoonBit 错误模型。对应上游 `client/internal/merr/`
（`milvus-io/milvus` commit `1bcc8cb1`，Apache-2.0）。

- `rpc_error.mbt` —— `MerError` suberror，code / legacy_code / detail / retriable / input 五元组
- `code_mapping.mbt` —— 双轨错误码映射表，逐条照搬上游 `modernCodeFromLegacy` / `legacyCodeFromModern`
- `sentinels.mbt` —— 预定义错误值，对应上游 `ErrCollectionNotFound` 等命名变量
- `wrap.mbt` —— `WrapErr*` 包装族，保留 code 身份、只改写文本
- `status.mbt` —— `Status` ↔ `MerError` 双向转换
- `redact.mbt` —— 敏感信息脱敏（上游没有，本项目新增的验收要求）

约定：
- `is_retryable_err` 只看服务端下发的 `Status.retriable`，不做本地猜测，
  与上游 `IsRetryableErr` 一致。retry 归属在 transport 层（#11）。
- `same_code` 是 Go 版 `errors.Is` 的等价物：**比对 code，不比对文本**。
- `MerError?` 上的方法在包外用 UFCS 调用（`@errors.error_code(err)`），
  点调用只对非 Option 的 `MerError` 有效。

## `client/` 包

Milvus 客户端门面与核心 RPC 编排，对应上游 `client/milvusclient/`
（`milvus-io/milvus` commit `1bcc8cb1`，Apache-2.0）。

- `types.mbt` —— `Unary` 函数值、`Client`、`ClientError`、`call_service`、`check_status`
- `consistency.mbt` / `schema_convert.mbt` —— 一致性等级与 schema ↔ proto 的桥
- `collection.mbt` —— CreateCollection / DropCollection / HasCollection /
  DescribeCollection / ListCollections 及其 Option
- `index.mbt` —— CreateIndex / DescribeIndex / DropIndex 及其 Option，
  把 `@index` 装配好的参数塞进请求、响应翻回 `@index.IndexDescription`
- `partition.mbt` —— Create / Drop / Has / ListPartitions 及其 Option
- `load.mbt` —— Load / Release Collection & Partitions、`LoadTask`、`GetLoadState`
- `flush.mbt` —— `Flush`、`FlushTask`、`GetFlushState`
- `write_column.mbt` / `write.mbt` —— `WriteColumn` → `FieldData`，insert / upsert / delete
- `search.mbt` / `query.mbt` —— 占位符编码、search_params、结果反序列化
- `paths.mbt` —— gRPC 方法路径常量
- `client/native/connect.mbt` —— native 专属：把 `Unary` 接到 `@channel.Client::unary`

约定：
- 发字节抽成 `pub type Unary = async (String, Bytes) -> Bytes raise @transport.RpcError`，
  所以 `client/` 在 wasm / js 下也编得过；真连 socket 的只有 `client/native`。
- `ClientError` 是**单一** suberror：`Transport` / `Server` / `Schema` / `Encode` / `Decode`。
  `async fn` 只允许一个 `raise` 类型，多错误组合装不进签名，所以这里是刻意的收敛。
- Milvus 老式 RPC 把错误放在响应体的 `common.Status` 里，而不是 gRPC status。
  每个响应都要过一遍 `check_status`，OK 返回 `None`。
- `ClientError` 的四个分类处置不同：`Transport` 可原样重试，`Server` 看
  `@errors.is_retryable_err`（只看服务端下发的 `retriable`，不做本地猜测）。
- 不缓存集合 schema：insert / upsert 的 `schema_timestamp` 留 0，
  没有上游那套 schema-mismatch 自动重试。这是 R6 里写明的取舍，改它要连带
  补一个 schema 缓存。
- `WriteColumn` 用 `@column.ColumnValue` 而不是另造枚举，让回读的 `Column`
  能改个名字写回去。它推导不出 `Array` 列的元素类型，所以那一支直接报 `Encode`。
- `search_params` 的键集合与顺序照搬上游 `AnnRequest.searchRequest`：
  固定七个键写全，调用方的 `with_search_param` 最后覆盖。
- **建索引 → 加载 → 检索的顺序不能倒**：Milvus 拒绝加载没有索引的集合
  （`index not found`），也拒绝对未加载的集合检索（`collection not loaded`）。
  加载是异步的，`load_collection` 返回不代表就绪，调用方要用 `LoadTask::wait`
  或 `get_load_state` 轮询到 `Loaded`。
- 状态枚举都保留生成物的 `Unknown` 岔路：`CollectionLoadState::Unknown` /
  `@index.IndexState::Unknown`。别把它们并进 `NotLoad` / `None`，那会把
  「没见过的状态」当成「什么都没发生」，然后无限等下去。
- `limit` 不预置，与上游 `NewQueryOption` 一致：不传就是服务端默认上限。
  想断言确定行数必须显式 `with_limit`。
- 写集成断言时别拿主键当行号：`auto_id` 发的是 Snowflake ID（18 位量级），
  `id >= 5` 这类条件等于全表通过。要按内容筛就用自己写的字段。
- `query` 的列名来自 `FieldData.field_name`。服务端在返回**全部字段**时
  （`with_output_fields(["*"])`，或调用方一个 `output_fields` 都没给）不填
  `field_name`，只有 `field_id`。这时客户端的 `output_fields` 会被逐个切掉、
  列名全空：`QueryResult::len` 读 `columns[0]` = 0，`column(name)` 也取不到，
  症状酷似「过滤条件被忽略、全量返回」——集成自检踩过。
  契约是：要看列名就必须在 `output_fields` 里逐点名，别用 `*`，也别留空。
- `LoadTask` / `FlushTask` 的 `wait` 照上游 `Await`：先等一个间隔再查第一次，
  默认 200ms。轮询用 `@async.sleep`（`moonbitlang/async` 是 `client` 的真依赖，
  不只是测试依赖），取消翻成 `Code::Cancelled` 的 `Transport` 错误。
- `has_partition` 用真 `HasPartition` RPC（`BoolResponse`），
  `has_collection` 用 `DescribeCollection`——两处不同是上游的选择，别顺手统一。

### 迭代器（`client/iterator.mbt`，对应上游 `iterator.go` / `iterator_option.go`）

- `QueryIterator` 是**客户端侧**游标：`DescribeCollection` 拿主键，之后每批
  把 `pk > last` 拼进 `expr` 往后挪。要求主键是 `Int64` / `VarChar`，
  否则建立时就报 `IteratorError::Setup`。
- `SearchIterator` 是**服务端侧** v2 游标：翻页凭据（`search_iter_id` /
  `search_iter_last_bound`）在响应 `SearchResultData.search_iterator_v2_results`
  上，跟命中一起回来。所以取数与挪游标在 `SearchIterator::fetch` 里一趟做完
  —— 分开做中间会有凭据是旧的窗口。
- 搜索迭代器的响应要拿整个 `SearchResultData`，`SearchResult` 装不下凭据，
  所以 `Client::search_call` 是共用的编排（校验 / 占位符 / 七个键 / status），
  `search` 与 `search_raw` 都从它过。改 `search_params` 的键集合只改这一处。
- 收尾走 `Client::cancel_search`：`nq = 0` + `search_input = NotSet`。
  走不了 `Client::search`，那条路要求至少一个查询向量、会用占位符填
  `search_input`。
- `SearchIterator` 走到末尾会自己发一次收尾请求。服务端侧游标不会自己过期，
  「不泄漏服务端资源」是 #18 的验收标准之一。
- 两处与上游刻意的差异，写在 `iterator.mbt` 文件头：nq 恒为 1（多给报错）、
  `limit` 不跨批截断（上游 `SearchIterator` 会切短）。改之前先读那段注释。
- 游标状态（`last` / `cursor` / `remaining`）在 `pub struct` 里标了 `priv`，
  外部只能通过 `next` / `close` / `is_closed` 操作。

`entity/` 的 float16 写侧（`float16_from_float` / `float16_vector_bytes`）与
`column/float16.mbt` 的读侧是一对，逐位对齐 IEEE-754 binary16。
改任一侧都要跑 `entity/float16_test.mbt`（期望值由 Python `struct.pack('<e')` 生成）。
