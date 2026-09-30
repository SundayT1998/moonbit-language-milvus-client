#!/usr/bin/env bash
# 用 protoc + protoc-gen-mbt 生成 MoonBit 代码。
#
# 生成物**直接落进主模块**：`proto/milvus/proto/...` 就是
# `Tangbuting/milvus-client` 的普通包目录，与 errors / client 同级。
# 没有第二个模块，也没有 moon.work —— 发布包自带全部依赖（见 README「安装」）。
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
# 该参数只影响生成器给包起的名字，产物落在哪由 --mbt_out 决定；
# 下面是生成后统一改写 import 路径，值本身不用改。
USERNAME=Tangbuting
# 生成的包目录挂到主模块名下的前缀：
#   Tangbuting/proto/milvus/proto/common  ->  Tangbuting/milvus-client/proto/milvus/proto/common
MODULE_NAME="$(sed -n 's/^name *= *"\(.*\)"/\1/p' "$ROOT/moon.mod" | head -1)"
[ -n "$MODULE_NAME" ] || { echo "读不到 moon.mod 的 name" >&2; exit 1; }

cat > "$ROOT/protoc-gen-mbt.sh" <<'EOF'
#!/bin/sh
exec moonx moonbitlang/protoc-gen-mbt@0.2.0 "$@"
EOF
chmod +x "$ROOT/protoc-gen-mbt.sh"

case "${1:-trimmed}" in
  upstream) SET=upstream ;;
  trimmed)  SET=trimmed ;;
  *) echo "用法: $0 [upstream|trimmed]" >&2; exit 2 ;;
esac

# 生成到临时目录再搬，别让 protoc 直接往版本库里的目录写：
# 一次失败的生成不该在源码树里留下半成品。
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

protoc -I"$ROOT/proto/$SET" \
  --plugin=protoc-gen-mbt="$ROOT/protoc-gen-mbt.sh" \
  --mbt_out="$STAGE" \
  --mbt_opt="project_name=$PROJECT_NAME,username=$USERNAME,paths=source_relative" \
  "$ROOT"/proto/"$SET"/*.proto

# protoc-gen-mbt 会给产物配一份 moon.mod.json（声明一个新模块）。
# 我们不用第二个模块，这份清单直接丢掉；剩下的纯包目录搬进主模块源码树。
GEN_SRC="$STAGE/$PROJECT_NAME/src/milvus/proto"
[ -d "$GEN_SRC" ] || { echo "生成物里找不到 $GEN_SRC" >&2; exit 1; }
OUT="$ROOT/proto/milvus/proto"
rm -rf "$OUT"
mkdir -p "$OUT"
cp -r "$GEN_SRC"/. "$OUT"/

# 探针测试作为源码叠加，避免被重新生成抹掉。
# p0test       : DescribeCollection 的 wire 往返（#10）
# indextest    : 索引 RPC 的 wire 往返（#16）
# rpctest      : Client 门面核心 RPC 的 wire 往返（#15）
# lifecycletest: 分区 / 加载 / flush 的 wire 往返（#17）
for suite in p0test indextest rpctest lifecycletest; do
  src="$ROOT/proto/tools/$suite"
  [ -d "$src" ] || continue
  dest="$OUT/$suite"
  mkdir -p "$dest"
  for f in "$src"/*.template; do
    cp "$f" "$dest/$(basename "$f" .template)"
  done
done

# 把生成物里的 import 路径从 Tangbuting/proto/... 改写到主模块名下。
# 生成器只会写「自己那个模块」的路径，所以这里是纯字符串替换；
# 只动 moon.pkg，不动 .mbt（.mbt 里不出现包路径）。
python3 - "$OUT" "$USERNAME" "$PROJECT_NAME" "$MODULE_NAME" <<'PY'
import sys
from pathlib import Path

root, user, project, new = (
    Path(sys.argv[1]),
    sys.argv[2],
    sys.argv[3],
    sys.argv[4],
)
# 生成器写的是 Tangbuting/proto/milvus/proto/common 这种全路径，
# 前缀是「用户名/工程名」而不是模块名，所以这里按这两段拼。
needle = f'"{user}/{project}/'
repl = f'"{new}/proto/'
total = 0
for pkg in sorted(root.rglob("moon.pkg")):
    text = pkg.read_text()
    if needle in text:
        total += text.count(needle)
        pkg.write_text(text.replace(needle, repl))
print(f"rewrote {total} import path(s): {user}/{project}/ -> {new}/proto/")
PY

# 生成器缺陷补丁（见 REPORT.md 第 4 节 Bug #1）：
# `repeated bytes` 字段的 JSON 编码漏了逐元素 base64，直接写成
#   @lib.base64_encode(self.<field>).to_json()
# 而 base64_encode 只收 Bytes，收不下 Array[Bytes]，编译不过。
# 生成器本身没法改，这里在生成后用 python 逐个字段判定：字段声明是
# `Array[Bytes]` 才补 `map(@lib.base64_encode)`，`Bytes` 保持原样。
# 等上游修好后这段可以连同 REPORT.md 的 Bug #1 一起删掉。
python3 "$ROOT/proto/tools/patch_repeated_bytes.py" "$OUT"

# 生成器不保证输出已格式化，而生成物现在入库、CI 又用 `moon fmt` 卡格式，
# 所以这里把它 fmt 掉。注意 `moon fmt <目录>` 不会往下递归，得逐个包调。
moon fmt "$OUT"/* >/dev/null

# 顺带把生成包的 .mbti 也刷新一遍（`moon info` 才会写）。
# 不刷的话 CI 里那步 `moon fmt && git diff --exit-code` 会先被 `moon info`
# 生成的文件顶出 diff —— 那句校验的是「仓库干净」，不止格式。
# 生成目录直接指定：`moon info` 不写 import 了它的那些包。
moon info "$OUT"/* >/dev/null

echo "生成完成 -> $OUT"
