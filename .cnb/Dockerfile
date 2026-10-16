# CNB 统一基础镜像：云原生构建（CI）与云原生开发（dev env）共用同一份 Dockerfile
# 基础镜像用 CNB 官方默认开发环境 cnbcool/default-dev-env（内含 code-server、node、git、ssh 等）
# MoonBit 工具链下载源固定为中国站 cli.moonbitlang.cn（CNB 侧统一使用 .cn）
# GitHub 侧（Actions）不使用本镜像，改为直接走 cli.moonbitlang.com
FROM cnbcool/default-dev-env:latest

ARG MOONBIT_CLI=https://cli.moonbitlang.cn

# cnbcool/default-dev-env 预装里没有 C 编译器与 glibc 头文件，
# 而 `moon test --target all` 的 native 后端需要它们，这里补上。
# 该镜像已把 apt 源换成腾讯云镜像，安装速度有保障。
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
        protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "${MOONBIT_CLI}/install/unix.sh" | bash

ENV PATH="/root/.moon/bin:${PATH}"

# 工具链版本写进层缓存键：升级 = 这个 ARG 变 = 下面这行 RUN 重跑。
# 不写的话 `RUN moon version --all` 这行永远是缓存命中 —— 缓存键只看命令
# 文本，而命令文本从没变过，于是 install 拿到的可能是上一个版本，
# 而 `proto/tools/gen.sh` 里 `moonx ...@0.2.0` 的 registry 缓存也是旧的。
# 这条在 CI 上真踩过：一次 pipeline 卡在 gen-proto 十分钟没输出然后被掐掉，
# 同一份代码前后两次跑结果不一致（见 #63）。
ARG MOONBIT_TOOLCHAIN=2026-10-12

RUN URL="$(curl -fsSL "${MOONBIT_CLI}/version.json" \
        | sed -n 's/.*"version" *: *"\([^"]*\)".*/\1/p' | head -1)" \
    && echo "resolved latest: ${URL}" \
    && case "${URL}" in *"${MOONBIT_TOOLCHAIN}"*) ;; \
       *) echo "工具链已漂到 ${URL}，与钉住的 ${MOONBIT_TOOLCHAIN} 不一致；" \
              "对齐后同步改这里与 docs/DEVELOPMENT.md" >&2 ;; \
       esac

RUN moon version --all
