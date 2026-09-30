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

## Development Environment

- CNB 云原生开发：在 `.cnb.yml` 的 `vscode` 事件中声明，与 CI 共用同一基础镜像
  `.cnb/Dockerfile`（基于 `cnbcool/default-dev-env`，MoonBit 工具链走中国站
  `cli.moonbitlang.cn`）。

## CI

- CNB 流水线：`.cnb.yml`，`push` / `pull_request` 跑 `moon fmt`、`moon info`、
  `moon check --target all`、`moon test --target all`。
- GitHub Actions：`.github/workflows/check.yml`（三平台检查），
  `.github/workflows/publish.yml`（手动触发发布到 mooncakes.io）。
- 工具链下载源：CNB 侧统一 `cli.moonbitlang.cn`，GitHub 侧统一 `cli.moonbitlang.com`。
- 本地等价命令：`moon check --target all && moon test --target all`。

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
- `proto/gen/` —— 生成产物，**不入版本库**（见 `.gitignore`）。
- `proto/tools/p0test/` —— 手写的 wire 往返测试模板，生成后由脚本叠加进产物。
- `proto/tools/gen.sh` —— 一键生成。`gen.sh upstream` 全量，`gen.sh trimmed` P0 集。
- `proto/REPORT.md` —— 生成器支持度探针报告（含已知缺陷与退路）。

要改生成结果，改 `.proto` 或 `gen.sh` 的参数，然后重新生成。

### 生成物与工作区接线

`proto/gen/` 不进版本库，所以签出后必须先跑一次生成，否则 `errors` 包
找不到 `Tangbuting/proto/milvus/proto/common`：

```sh
proto/tools/gen.sh trimmed                 # 生成 P0 裁剪集
moon work init . proto/gen/trimmed/proto   # 把生成模块注册进工作区
```

`moon.work` 是 `moon work init` 的产物，**需要进版本库**。`moon.mod` 里对
`Tangbuting/proto@0.1.0` 的依赖靠工作区解析到本地路径，不走 registry。

> 注意：`moon.mod` 不支持路径依赖，只有旧的 `moon.mod.json` 支持。因此这里
> 用「工作区成员 + 版本号依赖」的写法，别改成 `{ path = ... }`。

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
