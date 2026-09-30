# CNB 流水线 / 开发环境镜像：预装 MoonBit 工具链与 Native 目标所需的 C 工具链
# 由 `.cnb.yml` 的 docker.build 直接构建使用，无需推送制品库
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# CNB 环境走国内镜像源 cli.moonbitlang.cn 的安装脚本
# （GitHub Actions 走 cli.moonbitlang.com，见 .github/workflows/）
RUN curl -fsSL https://cli.moonbitlang.cn/install/unix.sh | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
