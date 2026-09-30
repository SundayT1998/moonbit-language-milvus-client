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
# 要读配置文件。CNB 云原生构建里 docker daemon 由 `services: - docker`
# 提供，`docker` 直接可用。
if ! command -v docker >/dev/null 2>&1; then
  echo "[milvus-start] 找不到 docker，无法起容器" >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "[milvus-start] docker daemon 不可达；CI 里请给任务加 services: - docker" >&2
  exit 1
fi

# 两份配置在容器内的落点。上游 `standalone_embed.sh` 也是放这里。
CONFIG_DIR=/milvus/configs
EMBED_ETCD=/milvus/configs/embedEtcd.yaml

# 配置文件先在本地生成，随后用 `docker cp` 拷进容器 —— 不用 `-v` bind mount。
#
# 为什么不用 bind mount：CNB 的 `services: - docker` 起的是 dind，daemon 在
# 另一个容器里，看不到本任务 `/tmp` 下的文件（跨容器共享的只有
# CNB_BUILD_WORKSPACE 与 docker.volumes 声明的目录）。源在 daemon 侧不存在时，
# Docker 的默认行为是在**目标路径建一个同名空目录**，于是
# `/milvus/configs/embedEtcd.yaml` 变成目录，`embed.ConfigFromFile` 读它失败。
# Milvus v3.0.2 的 `InitEtcdServer` 在 ConfigFromFile 失败时只记 initError 不返回，
# 紧接着 `cfg.Dir = dataDir` 解引用 nil，直接 SIGSEGV 退出
# （`pkg/util/etcd/etcd_server.go:49`）。`docker cp` 走 daemon API 传 tar，
# 与 daemon 在不在同一文件系统无关，本地 docker 和 CI dind 都成立。
WORKDIR="$(mktemp -d)"
EMBED_ETCD_SRC="$WORKDIR/embedEtcd.yaml"
USER_YAML_SRC="$WORKDIR/user.yaml"
cat > "$EMBED_ETCD_SRC" <<'YAML'
listen-client-urls: http://0.0.0.0:2379
advertise-client-urls: http://0.0.0.0:2379
quota-backend-bytes: 4294967296
auto-compaction-mode: revision
auto-compaction-retention: '1000'
YAML
cat > "$USER_YAML_SRC" <<'YAML'
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

CREATED=0
# create 之后到 start 之前的任何一步失败，都自己把容器收掉。
# 否则 cp 失败时会在 runner 上留一个 created 状态的空壳，
# 虽然 endStages 的 stop 脚本兜得住，但本地跑就会越积越多。
# shellcheck disable=SC2329  # 下面用 trap 调用，shellcheck 看不出来
cleanup_created() {
  if [ "$CREATED" = "1" ]; then
    docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
    CREATED=0
  fi
}
trap 'cleanup_created' EXIT

if [ -z "$(docker ps -q -f "name=^${CONTAINER}$")" ]; then
  # create → cp → start 三步。create 而非 run，是为了在容器跑起来之前把
  # 配置文件放到位：Milvus 启动即读 `/milvus/configs/embedEtcd.yaml`，
  # 先 start 再 cp 会读到不存在的路径。
  docker create \
    --name "$CONTAINER" \
    --security-opt seccomp=unconfined \
    -e ETCD_USE_EMBED=true \
    -e ETCD_DATA_DIR=/var/lib/milvus/etcd \
    -e ETCD_CONFIG_PATH="$EMBED_ETCD" \
    -e COMMON_STORAGETYPE=local \
    -e DEPLOY_MODE=STANDALONE \
    -p "127.0.0.1:${PORT}:19530" \
    --health-cmd="curl -f http://localhost:9091/healthz" \
    --health-interval=5s \
    --health-start-period=60s \
    --health-timeout=10s \
    --health-retries=60 \
    "$IMAGE" \
    milvus run standalone >/dev/null
  CREATED=1

  # `docker cp` 到具体文件路径时，目标文件名取自源文件名，所以这里逐份拷贝，
  # 保证容器内文件名与 ETCD_CONFIG_PATH 指向的一致。落成 root:root 无妨，
  # 容器内 milvus 用户只需可读（0644）。
  docker cp "$EMBED_ETCD_SRC" "${CONTAINER}:${EMBED_ETCD}"
  docker cp "$USER_YAML_SRC" "${CONTAINER}:${CONFIG_DIR}/user.yaml"

  # 自检：把两份配置从容器里 cp 回来，比字节数。容器还没 start，`docker exec`
  # 用不了，而 cp 对已创建未启动的容器是有效的。这步能同时挡住「没拷成
  # 普通文件」和「拷成了空目录/空文件」两种情形 —— 配置没到位时 Milvus 只会以
  # 一段难读的 panic 退场，不如在这里先给出明确原因。比大小而不是比内容：
  # 少一个对 `cmp`/`diffutils` 的依赖，这两份 yaml 又是本脚本自己写的。
  for pair in "$EMBED_ETCD_SRC:$EMBED_ETCD" "$USER_YAML_SRC:${CONFIG_DIR}/user.yaml"; do
    src="${pair%%:*}"; dst="${pair#*:}"
    back="$WORKDIR/$(basename "$dst").check"
    rm -f -- "$back"
    if ! docker cp "${CONTAINER}:${dst}" "$back" 2>/dev/null; then
      echo "[milvus-start] 配置文件没拷进容器：$dst" >&2
      exit 1
    fi
    # 拷回来是普通文件：大小与源一致（目录会被 cp 成目录，大小对不上）。
    if [ ! -f "$back" ] || [ "$(wc -c < "$src")" != "$(wc -c < "$back")" ]; then
      echo "[milvus-start] 配置文件没正确落到容器里：$dst" >&2
      exit 1
    fi
    rm -f -- "$back"
  done

  docker start "$CONTAINER" >/dev/null
  # 容器已经跑起来了，后续由 milvus-stop.sh 负责收尾，trap 不再删它。
  CREATED=0
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
