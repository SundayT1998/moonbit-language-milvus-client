#!/usr/bin/env bash
#
# 校验 README「快速上手」那段代码与 cmd/quickstart 里的副本逐字一致。
#
# 为什么要有这一道：MoonBit 的 `moon fmt` 对 ```moonbit 代码块默认只排版、
# 不检查，还会顺手把围栏改写成 ```moonbit nocheck —— 带了这个标记，示例
# 里写错函数名、参数对不上都不会有人发现。所以示例的可编译性靠
# `cmd/quickstart` 那个包兜底（`moon check` 会真编它），而那份副本和 README
# 之间只靠人肉同步，时间一长必然漂。这一步把「漂了」变成 CI 红。
#
# 用法：scripts/readme-quickstart-check.sh
set -euo pipefail

cd "$(dirname "$0")/.."

README="README.mbt.md"
PACKAGE="cmd/quickstart/quickstart.mbt"

if [ ! -f "${README}" ] || [ ! -f "${PACKAGE}" ]; then
  echo "[readme-check] 找不到 ${README} 或 ${PACKAGE}" >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

# 抠出 README 里第一段 ```moonbit 围栏的内容。
awk '
  /^```moonbit/ { if (inside) { exit } inside = 1; next }
  inside && /^```$/ { exit }
  inside { print }
' "${README}" > "${workdir}/readme.mbt"

# 抠出包里的代码：只去掉开头那段给读代码的人看的注释头。注释头是 `//` 起头，
# 而 `///|` 是块分隔符、属于示例的一部分 —— 它同样以 `//` 开头，所以必须显式
# 排除，否则会被当成注释一起吃掉（这个坑真踩过）。
awk '
  !started && (/^[[:space:]]*$/ || /^\/\//) && $0 !~ /^\/\/\/\|/ { next }
  { started = 1; print }
' "${PACKAGE}" > "${workdir}/package.mbt"

# 两边都掐掉首尾空行再比，免得空行数量成了噪音。
normalize() {
  awk 'NF || seen { seen = 1; lines[++n] = $0 }
       END { while (n > 0 && lines[n] == "") n--; for (i = 1; i <= n; i++) print lines[i] }' "$1"
}
normalize "${workdir}/readme.mbt" > "${workdir}/readme.norm"
normalize "${workdir}/package.mbt" > "${workdir}/package.norm"

if ! diff -u "${workdir}/package.norm" "${workdir}/readme.norm"; then
  echo "" >&2
  echo "[readme-check] README 的「快速上手」与 ${PACKAGE} 不一致。" >&2
  echo "              两份必须逐字相同：改了一边就改另一边。" >&2
  exit 1
fi

echo "[readme-check] README 快速上手与 ${PACKAGE} 一致"
