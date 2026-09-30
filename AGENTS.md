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

## entity 包

`entity/` 放协议无关的领域类型（`DataType` / `Field` / `CollectionSchema` / 各向量类型），
不 import `proto/gen/`，也不碰 wire 编解码。数值常量（`DataType::to_int`）与
`milvus.proto.schema` 逐条对齐，改动等于改协议，必须同步改 `entity/datatype_test.mbt`。

BF16 是手写实现，对 float32 做 bit 截断加 round-half-to-even，与上游 `ml_dtypes.bfloat16`
逐位一致；不要为了省事换成有损的近似算法。改这个函数要跑 `entity/bfloat16_test.mbt`。

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
