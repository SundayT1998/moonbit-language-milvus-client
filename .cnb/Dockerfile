# CNB 开发环境镜像：预装 MoonBit 工具链
# 构建：cnb docker build -f .cnb/Dockerfile -t docker.cnb.cool/tangbuting/moonbit:latest .
# 构建后推送到制品库即可作为流水线与开发环境的基础镜像
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
