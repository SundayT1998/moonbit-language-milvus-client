# CNB 统一基础镜像：云原生构建（CI）与云原生开发（dev env）共用同一份 Dockerfile
# MoonBit 工具链下载源固定为中国站 cli.moonbitlang.cn（CNB 侧统一使用 .cn）
# GitHub 侧（Actions）不使用本镜像，改为直接走 cli.moonbitlang.com
FROM debian:bookworm-slim

ARG MOONBIT_CLI=https://cli.moonbitlang.cn

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "${MOONBIT_CLI}/install/unix.sh" | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
