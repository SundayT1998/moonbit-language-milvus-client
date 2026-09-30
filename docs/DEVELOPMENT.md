# 开发记录

这份文档放**不该进 README 的东西**：任务分解、验收标准、调用方会踩到的实现
约定，以及过程中被推翻的方案与理由。README 面向使用者，只讲「怎么用」；
谁在哪个任务里做的、当初评估了哪几条路，属于项目内部记忆，落在这里。

任务与讨论的原始记录在仓库的 Issue / PR 里。**写完就地归档，不要往 Issue 里
回贴总结** —— Issue 是对话现场，不是档案室。结论沉淀到本文件或 `AGENTS.md`；
**还没做、打算做的事在 [`ROADMAP.md`](./ROADMAP.md)**，那份文件是
唯一的排期入口，不在这里维护第二份。

`docs/项目申报书.md` 是参赛用的申报材料，不属于上面这套文档分工 ——
它有成文的格式要求，只在申报节点更新。

## 开发流程

日常就一条命令：

```sh
moon check --target all && moon test --target all
```

改了 `proto/trimmed/*.proto` 才需要重新生成，需 `protoc`：

```sh
proto/tools/gen.sh trimmed
```

生成物在 `proto/milvus/proto/`，**已入版本库**；也不要手改，改动请在 `.proto`
或 `gen.sh` 里做，然后重新生成、把生成的 diff 一起提交。CI 每次都会重跑一遍
生成并 `git diff --exit-code`：生成物与 `.proto` 对不上时会直接红，不会悄悄漂走。

`moon fmt` 与 `moon info` 不应留下额外 diff：`.mbti` 变了说明对外接口变了，
值得在 PR 里说明。

改代码走 PR，别直接推 `main`。文档分工见 `AGENTS.md` 的「文档归属」：
README 面向使用者；本文件放过程与归档；`docs/ROADMAP.md` 放已规划未实现的能力；
Issue / PR 是对话现场，不是档案室。

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
- `load_collection` 返回只代表请求被受理，数据面就绪是异步的，所以要么
  `LoadTask::wait` 等进度到 100%，要么轮询 `get_load_state` 到 `Loaded`；
  直接接着检索会偶发失败。
- `Query` 的 `limit` 不预置，交给服务端默认；要确定行数就显式
  `with_limit(n)`。另外别拿主键当行号筛数据：`auto_id` 发的是 Snowflake ID，
  `id >= 5` 在 18 位的主键上等于全表通过。
- `Query` 必须逐点名 `output_fields`（如 `["id", "title"]`）。服务端在返回
  **全部字段**时（`["*"]`，或一个 `output_fields` 都不给）不填
  `FieldData.field_name`，只给 `field_id`：列名会全空，按名取列取不到，
  行数也会读成 0，症状看起来像「过滤条件没生效、全量返回」。

自检用 `new_flat_index(L2)`：10 行的集合上暴力检索就是最优解，也不用等索引构建。

embedded etcd 的配置文件用 `docker cp` 送进容器（`create` → `cp` → `start`），
不挂单文件卷：CI 的 docker daemon 跑在 dind 容器里，看不到本任务 `/tmp` 下的文件，
挂载源不可达时 docker 会把目标路径建成空目录，Milvus 读到目录会直接 segfault。
写新脚本时按同样方式处理配置文件。

### 上游同步策略

上游 `client/` 是持续演进的活跃代码，本移植是它在一个时间点上的快照。
同步策略是**手动评估、不自动合并**：

1. 定期（或按需）比对上游 `client/` 自基线 commit 以来的改动；
2. 对每处改动判断是否影响已移植的包（`entity` / `index` / `errors` / …）；
   **按语义判断，不按目录名机械对照**——MoonBit 侧的分包与上游并非一一对应；
3. 受影响则在对应包内手动回移，并在 PR 中注明对齐的上游 commit；
4. 需要推进基线时，同步更新 `README.mbt.md` 的「来源与许可」、
   `proto/upstream/PROVENANCE.md` 与 `AGENTS.md`。

不做自动同步的理由：上游一次目录级的机械同步会带来大量无法 review 的 diff，
而 MoonBit 侧的包边界本来就是重新划的，「同名目录改了就跟着改」会把上游的
重构噪音灌进来。宁可少跟几次，也不要把不可 review 的 diff 混进历史。

### 生成 proto 代码

```sh
proto/tools/gen.sh trimmed   # P0 + 索引 RPC 的裁剪集
proto/tools/gen.sh upstream  # 全量上游 proto（预期失败，见 proto/REPORT.md）
```

生成器的支持度探针结论在 `proto/REPORT.md`。

## 交付范围（P0）


一条完整的读写链路，拆成下面几块。

| 块 | 内容 |
|---|---|
| 可行性探针 | `protoc-gen-mbt` 对 Milvus proto 的支持度实测，结论见 `proto/REPORT.md` |
| `entity` | Schema / Field / Vector 抽象，BF16 手写转换 |
| `column` | `FieldData` → 列容器反序列化 |
| `index` | 索引参数 builder 与索引 RPC 编解码 |
| `errors` | `common.Status` → 错误模型与可重试判定 |
| `transport` | channel / 认证 / dbName / 超时，真连 socket 的部分按 target 切开 |
| `client` | 门面与核心 RPC：collection / insert / search / query |
| `client` 扩展 | partition / load / flush |
| 迭代器 | `QueryIterator`（客户端侧）/ `SearchIterator`（服务端侧 v2） |

## 验收标准

参照赛事要求逐条对齐，当前状态：

| # | 标准 | 状态 |
|---|---|---|
| 1 | MoonBit 为主，moonc ≥ 0.10.14 | 满足 |
| 2 | 公开仓库可访问，提交记录清晰 | 满足 |
| 3 | 源码结构清晰，核心功能可完成 | 满足 |
| 4 | README 覆盖目标 / 安装 / 用法 / 示例，可复现 | 满足 |
| 5 | CI 覆盖检查、构建、测试 | 满足 |
| 6 | 至少一个可运行示例 | 满足（`cmd/main`、`cmd/integration`） |
| 7 | 测试覆盖核心路径 | 满足，四 target 全绿 |
| 8 | 发布到 mooncakes.io | 见下节「发布」 |
| 9 | OSI 认可许可证，移植合规 | 满足，Apache-2.0 + 来源声明头 |

## 发布

包名 `Tangbuting/milvus-client`，版本随 `moon.mod`。

发布链路是 `.github/workflows/publish.yml`（手动触发）：先跑 fmt / check / test
的预检，通过后 `moon publish`，最后给发出去的 commit 打个 `v<version>` tag。

改 `moon.mod` 的 `version` 之后再触发；版本号不动，registry 会拒绝重复发布。


## 调用方需要知道的约定

这些原先写在 README 里，属于「用起来会踩到」的层面，但按文档分工不该待在
README。写代码和查问题时从这里找。

### `query` 的列名

`Query` 结果的列名来自 `FieldData.field_name`。服务端在返回**全部字段**时
（`with_output_fields(["*"])`，或一个 `output_fields` 都不给）不填
`field_name`，只给 `field_id`。这时客户端的 `output_fields` 会被逐个切掉、
列名全空：`QueryResult::len` 读 `columns[0]` 得 0，`column(name)` 也取不到，
症状看着像「过滤条件被忽略、全量返回」。

契约是：要看列名就必须在 `output_fields` 里逐点名，别用 `*`，也别留空。

`limit` 不预置，不传就是服务端默认上限，要断言确定行数得显式 `with_limit`。
写集成断言时别拿主键当行号：`auto_id` 发的是 Snowflake ID（18 位量级），
`id >= 5` 这类条件等于全表通过。

### 错误分流

传输失败与服务端拒绝是两个不同的 `ClientError` 分支：`Transport` 可以原样
重试，`Server` 要看 `@errors.is_retryable_err`（只看服务端下发的 `retriable`，
不做本地猜测）。判断某次失败是不是超时用 `is_deadline_exceeded`。

### 读取与写入的类型约定

- `column` 读错类型报 `ColumnError::DataTypeNotMatch`，null 行报 `NullValue`，
  不做隐式转换。窄整数按位宽有符号收窄：服务端把 `Int8` 放在 `int32` 数组里，
  `0xFF` 读成 -1。
- 可空列两种布局都认：`valid_data` 与数据等长（行满）或等于有效数（紧凑）。
  两处有效性位图不一致时报错，不挑一边。
- 动态字段（JSON）以 JSON 字符串取回，不做路径查询。
- Binary / Int8 向量列在 `@column.ColumnValue` 里是「逐行一块字节」，
  行内字节数按 `dim`（binary 按 `dim / 8`）校验。
- `WriteColumn` 不支持 `Array` 列：元素的 `DataType` 没法从值本身推出来，
  要写数组字段得先补一个带元素类型的列类型。

### 索引参数

`index` 包的参数 builder 与上游 Go SDK 的 `client/index` 对齐：键名、默认值、
枚举字面量逐条一致，非法组合在构造期报错（如
`IndexParamError::OutOfRange(key="M", value=1, expected=">= 2")`），
而不是等一次 RPC 往返。构建器没建模的参数走 `IndexParams::set` 兜底。

### 迭代器的几个点

- 走到末尾报 `IteratorError::EndOfIterator`，不是故障；`is_end_of_iterator`
  用来把它从 `while` 里放出来。`IteratorError::Closed` 才是「迭代器已经关了」。
- `SearchIterator::close` 会真的发一次空检索收掉服务端会话（服务端侧游标不会
  自己过期），翻到末尾时也自动收一次。失败不往上抛。
- `QueryIterator` 在服务端没有会话，`close` 只是本地标记。
- `with_limit` 是整体上限，只决定「还发不发下一次请求」，**不跨批截断**：
  `with_limit(10)` 配 `with_batch_size(100)` 时一次拿到 100 行。上游的
  `SearchIterator` 会切短超出上限的那一批，本移植统一不切。
- `SearchIterator` 依赖服务端实现 SearchIterator V2。老服务端不给
  `search_iterator_v2_results`，`next` 会报 `Setup`（上游这里是
  `ErrServerVersionIncompatible`）。

### 请求编排

- `search_params` 固定写全 `anns_field` / `topk` / `offset` / `metric_type` /
  `round_decimal` / `ignore_growing` / `params` 七个键，调用方的
  `with_search_param` 最后覆盖，与上游的键集合和顺序一致。
- `has_collection` 走 `DescribeCollection`，把 `CollectionNotExists` 当 `false`
  而不是失败；`has_partition` 走真 `HasPartition` RPC。两处不同是上游的选择。
- 未显式设一致性等级时，请求里 `use_default_consistency` 为真、等级填
  `Bounded`，由服务端决定最终档位。
- `LoadTask::wait` / `FlushTask::wait` 与上游 `Await` 一致，先等一个间隔再查
  第一次，间隔默认 200ms。取消会翻成 `Code::Cancelled` 的 `Transport` 错误。
- 状态枚举都保留 `Unknown` 岔路（`CollectionLoadState::Unknown` /
  `IndexState::Unknown`）。别把它们并进 `NotLoad` / `None` —— 那会把「没见过的
  状态」当成「什么都没发生」，然后无限等下去。

### 只在 native 下做的事

- 自检程序连上后发一次 Health/Check，失败以非 0 退出码结束。建连失败、
  Health/Check 报非超时错误都算失败，调用超时反而算通过 —— 那正是它要验的东西：

  ```sh
  moon run --target native cmd/main -- 127.0.0.1:19530 root:Milvus default
  ```

- 上层调用只要给一个 `Unary` 函数值就能跑，所以测试与 wasm 下不需要真连接：
  `@milvus_client.new_client(cfg, my_unary)`。

## 归档：几处被推翻或需要特别注意的选择

### 生成物为什么入库

早先是「生成物不入库 + 用 `moon.work` 把生成模块注册成第二个模块」。本地能跑，
但 `moon package` 打出来的 zip 里带着一份指向 `proto/gen/trimmed/proto` 的
`moon.work`，那个目录不在包里，装的人一解析工作区就挂；而且那个成员模块也不在
registry 上，依赖解析那步同样过不去。

试过的两条窄路都不通：

- **注册工作区成员**：工作区成员只对本地有效；成员模块的 `moon.mod` 不允许
  import 自己的包；两个同名同版本成员会报冲突。绕不过。
- **退回 `moon.mod.json` 用路径依赖**：能嵌，但会丢 `warnings` 等新清单的字段，
  且发布包体积从 7 个 `.proto` 变成整个生成物。

最终选了**生成物入库**：`proto/milvus/proto/` 就是主模块的普通包目录，与
`errors` / `client` 同级。`moon.work` 和第二份 `moon.mod` 一起消失。代价是改
`.proto` 会产生一大坨 diff —— 但那至少是**可以 review 的 diff**，比隐性坏账好。
顺带还多了一层防护：CI 每次重跑 `gen.sh` 后 `git diff --exit-code`，手改生成物
会当场红。

### `cmd/main` 的退出码

失败要以非 0 退出，否则脚本和 CI 会把「连不上」当通过。唯一的例外是**调用超时**
—— 那正是这个自检要验的第 3 条标准，当成失败这条标准就永远过不了。

### 集成测试的容器配置

embedded etcd 的两份配置用 `docker cp` 送进容器，不挂单文件卷：CNB 的
`services: - docker` 是 dind，daemon 在另一个容器里，看不到本任务 `/tmp` 下的文件，
挂载源不可达时 docker 会把目标路径建成空目录，Milvus 读到目录直接 SIGSEGV。
详见 `AGENTS.md`。

### README 的章节结构为什么照通用流程排

按「标题 → 描述 → 特性与能力边界 → 安装 → 快速上手 → 文档导航 → 贡献 →
许可证」这条通用顺序组织，理由不是形式统一，而是读者的阅读路径是单向的：
先知道这是什么、能不能解决我的问题，再决定要不要装，装完要一个能跑起来的东西，
跑通了才关心边界，最后才是怎么参与和许可证。

踩过的坑有两轮。

第一轮是**按包组织**：每个包一节、每节带完整 API 清单，读者要自己把「建集合」
「建索引」「加载」从三个小节里拼回来才能跑出第一个例子。改成一条打通的快速
上手之后，包级细节降级成「能力边界」下的子小节。

第二轮是**子小节又长回去了**：那些「传输层配置与自检 / entity / column /
index / 迭代器 / request 编排」小节，写的全是实现约定 —— 键集合、默认值、
构造期校验、状态枚举的岔路。这些是看代码或用出问题时才需要的东西，
不该占 README 的位置。这一轮把它们整段移出，落点在本文件的「调用方需要知道
的约定」与 `AGENTS.md` 的各包小节。

第三轮是**尾巴上又挂了一段命令**：两节删干净之后，快速上手底下还留着
「逐个函数的签名看 `.mbti`」加一段「从源码构建 / 改了 `.proto` 重新生成 /
连真 Milvus 跑集成测试」。这段跟正文没关系，是早先「开发」一节的残骸——
常见于把一节删掉时只删了标题，命令块原地留着。判断标准很简单：
**README 里出现的命令，读者照做是为了「用」还是为了「改」？**「用」的留下
（`moon add`），「改」的（check / test / gen / 起容器）归 `DEVELOPMENT.md`。
删的时候顺手往上翻一眼，看残留是不是拼到了上一节的末尾。

配套的几条边界：

1. **特性与能力边界合成一节。** 分两节写就是把同一件事说两遍。
2. **实现细节不进 README。** 只说「有这个能力」和「用起来有什么不同」，
   不说它是怎么实现的。
3. **API 清单不进 README。** 快速上手只体现主要 API，写一个能跑的链路即可；
   逐个函数的签名看 `.mbti` 与包内文档。
4. **状态信息不进 README。** 「某任务已交付」这类话会过期；能力清单跟着 API
   走，不跟着任务走，只有 API 真增删才动它。
5. **删内容之前先找落点。** 从 README 移走的东西，先确认在 `DEVELOPMENT.md`
   或 `AGENTS.md` 里有位置，别直接丢。
6. **构建命令不进 README。** 见上面第三轮：`moon check` / `moon test` /
   `gen.sh` / 集成测试三步都在本文件「开发流程」里，README 不写第二份。
   贡献一节也不拿命令凑数。

这些也写进了 `AGENTS.md` 的「文档归属」，免得下次再长回来。
