# GitHub Codespaces / devcontainer 镜像：MoonBit 工具链走国际站 cli.moonbitlang.com
# CNB 侧不使用此文件，CNB 统一用 .cnb/Dockerfile（中国站 cli.moonbitlang.cn）
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
