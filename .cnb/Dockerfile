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
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "${MOONBIT_CLI}/install/unix.sh" | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
