#!/usr/bin/env bash
# 用 protoc + protoc-gen-mbt 生成 MoonBit 代码。
#
# 前置：
#   - protoc 已安装（本项目 CI 用 3.21+，上游 protoc-gen-mbt 用 33.0）
#   - MoonBit 工具链在 PATH 中（提供 moonx）
#
# 用法：
#   proto/tools/gen.sh upstream   # 生成全量上游 proto（预期失败，见 REPORT.md）
#   proto/tools/gen.sh trimmed    # 生成 P0 裁剪集（预期成功）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

PROJECT_NAME=proto
USERNAME=Tangbuting

cat > "$ROOT/protoc-gen-mbt.sh" <<'EOF'
#!/bin/sh
exec moonx moonbitlang/protoc-gen-mbt@0.2.0 "$@"
EOF
chmod +x "$ROOT/protoc-gen-mbt.sh"

case "${1:-trimmed}" in
  upstream)
    OUT="$ROOT/proto/gen/upstream"
    rm -rf "$OUT"; mkdir -p "$OUT"
    # 注意 -I 指向 proto/upstream，否则 import 无法解析
    protoc -I"$ROOT/proto/upstream" \
      --plugin=protoc-gen-mbt="$ROOT/protoc-gen-mbt.sh" \
      --mbt_out="$OUT" \
      --mbt_opt="project_name=$PROJECT_NAME,username=$USERNAME,paths=source_relative" \
      "$ROOT"/proto/upstream/*.proto
    ;;
  trimmed)
    OUT="$ROOT/proto/gen/trimmed"
    rm -rf "$OUT"; mkdir -p "$OUT"
    protoc -I"$ROOT/proto/trimmed" \
      --plugin=protoc-gen-mbt="$ROOT/protoc-gen-mbt.sh" \
      --mbt_out="$OUT" \
      --mbt_opt="project_name=$PROJECT_NAME,username=$USERNAME,paths=source_relative" \
      "$ROOT/proto/trimmed/milvus.proto" \
      "$ROOT/proto/trimmed/schema.proto" \
      "$ROOT/proto/trimmed/common.proto"
    ;;
  *)
    echo "用法: $0 [upstream|trimmed]" >&2
    exit 2
    ;;
esac

# 生成的模块里，protoc-gen-mbt 产出的 moon.mod.json 会触发 200+ 条
# implicit_impl_as_method 弃用告警（生成器风格，非本仓库可修）。统一静音，
# 让 `moon check` 的输出只反映手写代码的问题。
cat > "$OUT/proto/moon.mod" <<'MOD'
name = "Tangbuting/proto"

version = "0.1.0"

source = "src"

warnings = "-implicit_impl_as_method"

import {
  "moonbitlang/protobuf@0.1.3",
}
MOD
rm -f "$OUT/proto/moon.mod.json"

# 生成器缺陷补丁（见 REPORT.md 第 4 节 Bug #1）：
# `repeated bytes` 字段的 JSON 编码漏了逐元素 base64，直接写成
#   @lib.base64_encode(self.<field>).to_json()
# 而 base64_encode 只收 Bytes，收不下 Array[Bytes]，编译不过。
# 生成器本身没法改，这里在生成后用 python 逐个字段判定：字段声明是
# `Array[Bytes]` 才补 `map(@lib.base64_encode)`，`Bytes` 保持原样。
# 等上游修好后这段可以连同 REPORT.md 的 Bug #1 一起删掉。
if [ -d "$OUT/proto/src/milvus/proto" ]; then
  python3 "$ROOT/proto/tools/patch_repeated_bytes.py" "$OUT/proto/src"
fi

# 探针测试作为源码叠加，避免被重新生成抹掉。
# p0test  : DescribeCollection 的 wire 往返（#10）
# indextest: 索引 RPC 的 wire 往返（#16）
if [ -d "$OUT/proto/src/milvus/proto" ]; then
  for suite in p0test indextest; do
    src="$ROOT/proto/tools/$suite"
    [ -d "$src" ] || continue
    dest="$OUT/proto/src/milvus/proto/$suite"
    mkdir -p "$dest"
    for f in "$src"/*.template; do
      cp "$f" "$dest/$(basename "$f" .template)"
    done
  done
fi

echo "生成完成 -> $OUT"
