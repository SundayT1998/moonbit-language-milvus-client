# CNB 统一基础镜像：云原生构建（CI）与云原生开发（dev env）共用同一份 Dockerfile
# 基础镜像用 CNB 官方默认开发环境 cnbcool/default-dev-env（内含 code-server、node、git、ssh 等）
# MoonBit 工具链下载源固定为中国站 cli.moonbitlang.cn（CNB 侧统一使用 .cn）
# GitHub 侧（Actions）不使用本镜像，改为直接走 cli.moonbitlang.com
FROM cnbcool/default-dev-env:latest

ARG MOONBIT_CLI=https://cli.moonbitlang.cn

# cnbcool/default-dev-env 预装里没有 C 编译器与 glibc 头文件，
# 而 `moon test --target all` 的 native 后端需要它们，这里补上。
# 该镜像已把 apt 源换成腾讯云镜像，安装速度有保障。
# `Check-Valid-Until=false` 不是可选项：腾讯云的 `trixie-updates` 索引在
# `Valid-Until` 到点后有一段窗口是**过期未刷新**的（这次实测 10 分钟量级）。
# 窗口里 InRelease 与 Packages 都下得下来，只是签名里的有效期没续上，
# apt 于是判该仓库失效并以 100 退出 —— `apt-get install` 跟着失败，
# 整个 Docker build 挂在第 2 层，CI 的 Prepare 阶段红，四个 stage 一个都跑不到。
#
# 本地实测（同一台机器、同一 base 镜像、同一分钟）：
#   apt-get update                                  -> E: ...的 Release 文件已经过期, exit 100
#   apt-get -o Acquire::Check-Valid-Until=false update -> 0，后续 install 正常
# 与镜像站窗口期绑定的偶发失败，不是每次必挂，也不是 `--no-cache` 能绕过的
# （同一份索引对谁都过期）。
#
# 只关有效性检查，不关签名：签名仍按 keyring 校验，取到的包还是可信的。
# 这份 Dockerfile 只构建 CI / dev 镜像，不为生产分发签名。
RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
        protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "${MOONBIT_CLI}/install/unix.sh" | bash

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
