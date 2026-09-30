# 开发记录

这份文档放**不该进 README 的东西**：任务分解、验收标准、以及过程中被推翻的
方案与理由。README 面向使用者，只讲「怎么用」和「为什么这么设计」；
谁在哪个任务里做的、当初评估了哪几条路，属于项目内部记忆，落在这里。

任务与讨论的原始记录在仓库的 Issue / PR 里。**写完就地归档，不要往 Issue 里
回贴总结** —— Issue 是对话现场，不是档案室。结论沉淀到本文件或 `AGENTS.md`。

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
