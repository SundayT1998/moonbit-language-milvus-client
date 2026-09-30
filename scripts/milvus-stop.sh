#!/usr/bin/env bash
#
# 停掉 scripts/milvus-start.sh 起的 Milvus 容器。
# CI 里放在 `always()` 收尾步骤：测试失败也要停，别把容器漏在 runner 上。
#
# 用法：
#   scripts/milvus-stop.sh            # 停掉并删除容器
#   scripts/milvus-stop.sh --keep     # 只停不删（本地调试要保住数据卷时用）
#
# 环境变量：
#   MILVUS_CONTAINER  容器名（默认 milvus-integration）
set -euo pipefail

CONTAINER="${MILVUS_CONTAINER:-milvus-integration}"
KEEP=0
[ "${1:-}" = "--keep" ] && KEEP=1

if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
  echo "[milvus-stop] docker 不可用，跳过"
  exit 0
fi

# start 脚本为挂载生成过一份临时配置目录，这里顺手收掉。
# 只删 mktemp 明确产出的路径形态：直接 `rm -rf "$(cat 文件)"` 等于把删除目标
# 交给文件内容，文件一旦被换掉（或残留自上一次构建）就会删到别处去。
#
# 这段必须在「容器不存在就跳过」之前：start-milvus 失败时容器很可能根本没能
# 建出来，那时更要收掉这份配置目录，否则每失败一次就在 runner 上留一份。
workdir_file="${MILVUS_WORKDIR_FILE:-/tmp/milvus-workdir}"
if [ -f "$workdir_file" ]; then
  workdir="$(cat "$workdir_file")"
  case "$workdir" in
    /tmp/tmp.*|/var/folders/*) rm -rf -- "$workdir" 2>/dev/null || true ;;
    *) echo "[milvus-stop] 路径 $workdir 不像 mktemp 产物，不删" >&2 ;;
  esac
  rm -f -- "$workdir_file"
fi

if [ -z "$(docker ps -aq -f "name=^${CONTAINER}$")" ]; then
  echo "[milvus-stop] 容器 $CONTAINER 不存在，跳过"
  exit 0
fi

if [ "$KEEP" = "1" ]; then
  docker stop "$CONTAINER" >/dev/null 2>&1 || true
  echo "[milvus-stop] 容器 $CONTAINER 已停止（保留）"
else
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
  echo "[milvus-stop] 容器 $CONTAINER 已停止并删除"
fi
