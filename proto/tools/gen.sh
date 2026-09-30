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

# P0 探针测试作为源码叠加，避免被重新生成抹掉
if [ -d "$ROOT/proto/tools/p0test" ] && [ -d "$OUT/proto/src/milvus/proto" ]; then
  DEST="$OUT/proto/src/milvus/proto/p0test"
  mkdir -p "$DEST"
  for f in "$ROOT"/proto/tools/p0test/*.template; do
    cp "$f" "$DEST/$(basename "$f" .template)"
  done
fi

echo "生成完成 -> $OUT"
