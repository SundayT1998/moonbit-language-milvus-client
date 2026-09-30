# Phase 0 探针报告：`protoc-gen-mbt` 对 Milvus proto 的支持度

> 结论先行：**可行**。全量生成能跑通，卡在 2 个生成器缺陷上；
> 用「裁剪到 P0 子集」的退路可 100% 通过 `moon check` + `moon test`。

## 1. 环境

| 项 | 版本 |
|---|---|
| MoonBit CLI | `moon 0.1.20260920 (914d7da)` |
| 生成器 | `moonbitlang/protoc-gen-mbt@0.2.0`（经 `moonx` 调用） |
| protoc | `libprotoc 3.21.12` |
| 运行时 | `moonbitlang/protobuf@0.1.3` |

复现命令：

```sh
proto/tools/gen.sh upstream   # 全量（预期 1 个 error）
proto/tools/gen.sh trimmed    # P0 裁剪集（预期 0 error）
```

## 2. 上游来源修正

Issue 原文说取自 `milvus-io/milvus` 的 `client/` 目录，实际**不在**该仓库。
`milvus.proto` / `schema.proto` / `common.proto` 位于独立仓库
[`milvus-io/milvus-proto`](https://github.com/milvus-io/milvus-proto) 的 `proto/` 目录。

- 锚定 commit：`ae7fea6ab2f4e958f2feef0f0edb9a0d23fa7e0c`
- 依据：`milvus@1bcc8cb1` 的 `go.mod` 引用 `milvus-proto/go-api/v3@v3.0.0-20260914122923-ae7fea6ab2f4`
- 三文件共 5126 行，与 Issue 描述的「约 5.1k 行」吻合

`milvus.proto` 还 `import` 了 `rg.proto` / `feder.proto` / `msg.proto`，
缺了它们无法完整解析，已一并放入 `proto/upstream/`。

## 3. 生成器踩坑

### 3.1 必须给 `-I`，否则 import 全线失败

Issue 里的原始命令没带 `-I`，protoc 会把 `import "common.proto"` 判为找不到，
进而报出 **2000+ 行**「`common.Status` is not defined」的连锁错误。
加上 `-I proto/upstream` 后，同样的输入 **0 error** 生成成功。

### 3.2 必须传 `username=`，否则生成物互相引用会断

生成器把 `username/proto/...` 硬编码进包 import 路径。
不传 `username` 时 `moon check` 直接报：
`Cannot find import 'username/proto/milvus/proto/common'`。
传 `username=Tangbuting` 后模块名与 import 自洽。

### 3.3 纠正一处 API 文档偏差

README 示例写的是 `mbt_opt=...`，实际 `protoc` 只认 `--mbt_opt=...`。

## 4. 全量生成结果

产物 7 个包、**65183 行** MoonBit，`moon check --target all`：

- 错误：**1**
- 警告：586（其中 584 条是 `implicit_impl_as_method` 弃用提示，非阻塞）

### Bug #1 — `repeated bytes` 的 JSON 序列化生成错误

```
common.proto:164   repeated bytes values = 3;   // message PlaceholderValue
```

生成物（`common/top.mbt:3690`）：

```moonbit
json["values"] = @lib.base64_encode(self.values).to_json()
//                                  ~~~~~~ Array[Bytes]，base64_encode 只收 Bytes
```

`base64_encode(Bytes) -> String`，而 `self.values` 是 `Array[Bytes]`。
**类型不匹配，编译失败。** 生成器漏了对 `repeated bytes` 的逐元素 map。
全量 10 处 `repeated bytes` 字段都会命中。

### Bug #2 — 大文件中 `optional` 字段的读取实现被误判为标签参数

```
milvus.proto:2974   optional RowPolicyType policy_type = 10;
```

生成物（`milvus/top.mbt:17954`，对应 `UpdateCredentialRequest`）：

```moonbit
(7, _) => msg.description = reader |> @lib.read_string() |> Some
```

第 17954 行报：

```
Error: [3016] The syntax `init~=..` for supplying labelled argument is invalid,
              the correct syntax is `init=..`.
```

诡异点：**同一文件里其它 20+ 处写法完全一致的同款语句都能编过**，
且该行单独抽出来编译也没问题 —— 属编译器/生成器的规模相关缺陷，非单行语法错。
进一步验证：把字段改名（`description` → `desc_field`）错误位置不变，
说明与字段名无关，与 `optional` + 文件体量有关。

> 注：`optional` 本身在小文件里工作正常（`proto/tools` 的 smoke 用例可证），
> 只有放进 `milvus.proto` 这种 4.4 万行的生成物才触发。

## 5. 特性支持矩阵（按 Issue 要求逐项验证）

| 特性 | 结果 | 证据 |
|---|---|---|
| `map<K,V>` | ✅ | `mut properties : Map[String, String]` |
| 嵌套 message | ✅ | `MsgBase_PropertiesEntry`（扁平化命名） |
| `optional` | ⚠️ 小文件 ✅ / 大文件 ❌ | 见 Bull #2 |
| `oneof` | ✅ | `SearchRequest_SearchInput::{NotSet,PlaceholderGroup,Ids}` |
| `repeated`（基本类型） | ✅ | `mut aliases : Array[String]` |
| `repeated bytes` + JSON | ❌ | 见 Bull #1（关掉 JSON 也仅是换一个错） |
| `google.protobuf.Any` | N/A | 三个目标文件**不使用** Any |
| `extensions` / 自定义 option | 🟡 被忽略但**无害** | `extend google.protobuf.MessageOptions` / `FileOptions` 生成物中无对应代码；`option (common.privilege_ext_obj)` 被静默丢弃，不影响 message 定义 |
| deprecated `group` | N/A | 三个目标文件**不使用** group（注释里的 "group" 是词不是语法） |

### Known Issues 的影响评估

README 列的两条 Known Issue，对 P0 都**不构成阻塞**：

1. **deprecated group 不支持** —— P0 相关 message 完全不用 group。
2. **extensions 与自定义 option 被忽略** —— Milvus 用它们挂 RBAC 权限元数据
   (`privilege_ext_obj` / `milvus_ext_obj`)，服务端才读；
   **客户端**（本项目的定位）不需要这些，忽略即可。

## 6. P0 结论：`DescribeCollection` 所需 message 完整可用

裁剪集（退路 a）从 `DescribeCollectionRequest/Response` 出发做传递闭包：

- `common`：5 message + 3 enum
- `schema`：8 message + 4 enum
- `milvus`：2 message

合计 **15 message + 7 enum**，与 Issue 预估的「约 15 个 message」一致。
裁剪后：

```
moon check --target all  ->  0 error
moon test  --target wasm  ->  3 passed
moon test  --target wasm-gc -> 3 passed
moon test  --target js    ->  3 passed
```

`proto/gen/trimmed/proto/src/milvus/proto/p0test/wire_test.mbt` 里三个测试：

1. `DescribeCollectionRequest` 编解码往返，字段值全部还原
2. `size_of` 与编码字节数一致
3. gRPC 风格「长度前缀 + body」payload 往返

即：**P0 所需 message 的 wire codec 是正确可用的**，可以直接接 `moonrpc`。

## 7. 退路评估（Issue 要求必须写明）

- **(a) 裁剪 `.proto` 到生成器支持的子集** —— ✅ **已验证可行**，见第 6 节。
  代价：需要维护一份裁剪脚本；上游 proto 变更时要同步。
  裁剪集现放在 `proto/trimmed/`。
- **(b) 手写 wire codec** —— ❌ **无必要**。生成物在裁剪后已能编译、
  且 wire 往返正确，没有理由放弃生成器。

## 8. 建议

1. 采纳退路 (a)：`proto/trimmed/` 作为 P0 的唯一生成输入，`proto/upstream/` 只读留档。
2. 向 `moonbitlang/protoc-gen-mbt` 提 2 个 issue（repeated bytes JSON / optional 大规模）。
   修好后可去掉裁剪，直接生成全量。
3. `moon test --target native` 当前环境缺 cc；CI 里需保证 `gcc` 或 `MOON_CC` 可用
   （`.cnb/Dockerfile` 已装了 `gcc libc6-dev`）。
4. 生成物**不手改**，见 `AGENTS.md` 新增章节。

## 9. 复现清单

```
proto/
  upstream/     # 上游只读快照（7 个 .proto + PROVENANCE.md）
  trimmed/      # P0 裁剪集（3 个 .proto）
  gen/          # 生成物（不进版本库，见 .gitignore）
  tools/gen.sh  # 一键生成
  tools/p0test/     # DescribeCollection 的 wire 往返测试（#10）
  tools/indextest/  # 索引 RPC 的 wire 往返测试（#16）
  REPORT.md     # 本文件
```

## 10. 追加：索引 RPC 的 message 纳入裁剪集（#16）

`#16` 需要 `CreateIndex` / `DescribeIndex` / `DropIndex`，裁剪集因此扩大了
5 个 message：

| 文件 | 新增 |
|---|---|
| `trimmed/milvus.proto` | `CreateIndexRequest` / `DescribeIndexRequest` / `IndexDescription` / `DescribeIndexResponse` / `DropIndexRequest` |
| `trimmed/common.proto` | `IndexState` 枚举 |

顺带删掉了这 5 个 message 上的 `option (common.privilege_ext_obj)`：
它是服务端读的 RBAC 元数据，且裁剪集里没有 `privilege_ext_obj` 的
`extend` 声明，留着会报「not defined」。客户端不需要，删掉不影响语义。

**这 5 个 message 不用 `optional`**，因此绕开了第 4 节的 Bug #2；
也不含 `repeated bytes`，绕开 Bug #1。裁剪后结果：

```
moon check --target all  ->  0 error
moon test  --target all  ->  7 passed（3 个 p0test + 4 个 indextest），四目标全绿
```

`tools/indextest/` 的四个测试：

1. `CreateIndexRequest` 编解码往返，`extra_params` 四条键值对全部还原
2. `size_of` 与编码字节数一致
3. `DropIndexRequest` 编解码往返
4. `DescribeIndexResponse` 编解码往返，嵌套的 `IndexDescription` 与
   `common.IndexState` 枚举值正确

即：索引 RPC 的入参/出参 wire codec 已验证可用，接 `moonrpc` 只剩传输层。

## 11. 追加：响应 `FieldData` 纳入裁剪集（#14）

`#14` 需要把响应里的 `FieldData` 解成列，裁剪集因此再扩 20 个 message：
`FieldData` / `ScalarField` / `VectorField` / `VectorArray` / `SparseFloatArray`
以及 `BoolArray` / `IntArray` / `LongArray` / `FloatArray` / `DoubleArray` /
`BytesArray` / `StringArray` / `UUIDArray` / `ArrayArray` / `JSONArray` /
`GeometryArray` / `GeometryWktArray` / `TimestamptzArray`，另加 `IDs`。
字段号一律照抄 `proto/upstream/schema.proto`。

`FieldData.field` oneof 里的 `struct_arrays = 8` 没纳入——`ArrayOfStruct` /
`Struct` 不在本 Issue 的范围，带上它会把 `StructArrayField` 一整串拖进来。
少了这一支后 oneof 只剩 `scalars` / `vectors`，读的一侧不可能解出结构数组。

### 这回撞上了 Bug #1，并修好了

`FieldData` 这一族里有 `repeated bytes`（`BytesArray.data`、`JSONArray.data`、
`GeometryArray.data`、`UUIDArray.data`、`SparseFloatArray.contents`），
正好命中第 4 节的 **Bug #1**：生成器把它们编成

```moonbit
json["data"] = @lib.base64_encode(self.data).to_json()
```

而 `base64_encode(Bytes) -> String` 收不下 `Array[Bytes]`，5 处编译不过。

`proto/tools/gen.sh` 因此多了一步后处理：
`proto/tools/patch_repeated_bytes.py` 在生成后按**结构体字段声明**判定，
字段是 `Array[Bytes]` 才补 `map(@lib.base64_encode)`，`Bytes` 字段原样不动。
该脚本是文本补丁、不是语义重写，所以判据是「同文件里既有
`mut <f> : Array[Bytes]` 声明、又有 `base64_encode(self.<f>).to_json()`」两条
同时成立才改，宁可漏判题。上游修好 Bug #1 后，这个脚本连同本节一起删。

顺带纠一处：第 4 节原本说「`repeated bytes` + JSON 关掉也仅是换一个错」，
在**裁剪集**里不成立——把这 5 处 JSON 编码改对之后，其余代码不受影响，
`moon check` 干净通过。也就是说 Bug #1 只在 P0 没碰 `repeated bytes` 时被绕过，
不是无法回避。

### 结果

```
moon check --target all  ->  0 error
moon test  --target all  ->  130 passed，四目标全绿
```

其中 `column/` 包 20 条测试覆盖：标量各类型、窄整数有符号收窄、空列、
null 行（紧凑与行满两种布局）、行区间切片、`valid_data` 双源冲突、
`FloatVector` / `BinaryVector` / `Float16Vector` / `BFloat16Vector` /
`Int8Vector` / `SparseFloatVector`、向量 payload 类型不符、动态字段 JSON
字符串与 UTF-8 校验、`Array` 列、读错类型、不支持的字段类型。
