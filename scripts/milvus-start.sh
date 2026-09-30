#!/usr/bin/env bash
#
# 起一个 Milvus standalone 容器，用来跑集成测试。
#
# 容器参数照搬上游 `milvus-io/milvus` 的 `scripts/standalone_embed.sh`：
# 官方镜像 + embedded etcd + local 存储，一个容器自足，不需要 etcd/MinIO 两个旁挂。
# 固定版本号而不是 `latest`：CI 结果要可复现，镜像换底是显式动作。
#
# 用法：
#   scripts/milvus-start.sh            # 起容器并等到就绪
#   scripts/milvus-start.sh --force    # 先删掉同名残留容器再起
#
# 环境变量：
#   MILVUS_IMAGE      镜像名（默认 docker.io/milvusdb/milvus:v3.0.2）
#   MILVUS_CONTAINER  容器名（默认 milvus-integration）
#   MILVUS_PORT       宿主 gRPC 端口（默认 19530）
#   MILVUS_WAIT_SECS  等就绪的最长秒数（默认 600）
#   MILVUS_LOG_TAIL   超时时打印的容器日志行数（默认 200）
set -euo pipefail

IMAGE="${MILVUS_IMAGE:-docker.io/milvusdb/milvus:v3.0.2}"
CONTAINER="${MILVUS_CONTAINER:-milvus-integration}"
PORT="${MILVUS_PORT:-19530}"
WAIT_SECS="${MILVUS_WAIT_SECS:-600}"
FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# 本脚本用 rootful docker：容器内 milvus 用户需要写卷，且 embedded etcd
# 要读挂进去的配置文件。CNB 云原生构建里 docker daemon 由
# `services: - docker` 提供，`docker` 直接可用。
if ! command -v docker >/dev/null 2>&1; then
  echo "[milvus-start] 找不到 docker，无法起容器" >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "[milvus-start] docker daemon 不可达；CI 里请给任务加 services: - docker" >&2
  exit 1
fi

# embedded etcd 的配置。上游把这两份 yaml 挂进容器，是为了让
# embedded etcd 监听在容器内的 2379，而不是默认的 127.0.0.1。
WORKDIR="$(mktemp -d)"
EMBED_ETCD="$WORKDIR/embedEtcd.yaml"
USER_YAML="$WORKDIR/user.yaml"
cat > "$EMBED_ETCD" <<'YAML'
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://0.0.0.0:2379
quota-backend-bytes: 4294967296
auto-compaction-mode: revision
auto-compaction-retention: '1000'
YAML
cat > "$USER_YAML" <<'YAML'
# Extra config to override default milvus.yaml
YAML
echo "[milvus-start] config 目录：$WORKDIR"

# 同名容器还在：--force 删掉重来，否则复用（重复调用不会起第二个）。
if [ -n "$(docker ps -aq -f "name=^${CONTAINER}$")" ]; then
  if [ "$FORCE" = "1" ]; then
    echo "[milvus-start] 删除已存在的容器 $CONTAINER"
    docker rm -f "$CONTAINER" >/dev/null
  fi
fi

if [ -z "$(docker ps -q -f "name=^${CONTAINER}$")" ]; then
  docker run -d \
    --name "$CONTAINER" \
    --security-opt seccomp=unconfined \
    -e ETCD_USE_EMBED=true \
    -e ETCD_DATA_DIR=/var/lib/milvus/etcd \
    -e ETCD_CONFIG_PATH=/milvus/configs/embedEtcd.yaml \
    -e COMMON_STORAGETYPE=local \
    -e DEPLOY_MODE=STANDALONE \
    -v "$EMBED_ETCD:/milvus/configs/embedEtcd.yaml:ro" \
    -v "$USER_YAML:/milvus/configs/user.yaml:ro" \
    -p "127.0.0.1:${PORT}:19530" \
    --health-cmd="curl -f http://localhost:9091/healthz" \
    --health-interval=5s \
    --health-start-period=60s \
    --health-timeout=10s \
    --health-retries=60 \
    "$IMAGE" \
    milvus run standalone >/dev/null
  echo "[milvus-start] 容器已启动，等待 healthy"
else
  echo "[milvus-start] 容器已在运行，等待 healthy"
fi

# 就绪判据是容器内 9091/healthz 返回 200，与上游 `wait_for_milvus_running`
# 等价。但这里不读 docker 的 health 状态：
#   - Moby 的健康状态机一旦因重试耗尽被打成 `unhealthy`，就是终态，后面即使
#     服务真的起来了也不会再翻回 `healthy`。Milvus 冷启动在 CI 上耗时不定，
#     任何固定的 start-period/retries 都可能被穿破，一破就永久卡死。
#   - 反过来，直接从宿主探活就没有这个终态问题：探到 200 就算就绪。
# 9091 只在健康检查里用得到，不用映射到宿主，所以用 docker exec 在容器里打。
# 探 19530 不够 —— 端口在数据面就绪之前就监听了，上次就是这么踩的坑。
probe_ready() {
  docker exec "$CONTAINER" curl -fsS -o /dev/null http://localhost:9091/healthz >/dev/null 2>&1
}

for i in $(seq "$WAIT_SECS"); do
  if probe_ready; then
    echo "[milvus-start] Milvus 就绪：127.0.0.1:${PORT}"
    echo "$WORKDIR" > "${MILVUS_WORKDIR_FILE:-/tmp/milvus-workdir}"
    exit 0
  fi

  # 容器死了就别再等了，直接把日志甩出来。
  state="$(docker inspect -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null || echo gone)"
  case "$state" in
    gone|exited|dead)
      echo "[milvus-start] 容器已${state}，日志如下：" >&2
      docker logs "$CONTAINER" >&2 || true
      exit 1
      ;;
  esac

  # 每 15 秒报一次进度，免得长等待期间日志一片空白、看不出在等什么。
  if [ $((i % 15)) -eq 0 ]; then
    echo "[milvus-start] 已等待 ${i}s，仍未就绪"
  fi
  sleep 1
done

echo "[milvus-start] ${WAIT_SECS}s 内 9091/healthz 没返回 200，日志尾部：" >&2
# 默认只给 200 行：Milvus 启动失败时往往先喷一大段 goroutine dump，
# 真正的原因（比如配置读不到、端口占用）夹在中间，tail 太短会把它截掉。
docker logs --tail "${MILVUS_LOG_TAIL:-200}" "$CONTAINER" >&2 || true
exit 1
