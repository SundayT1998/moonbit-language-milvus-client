# CNB 流水线 / 开发环境镜像：预装 MoonBit 工具链与 Native 目标所需的 C 工具链
# 由 `.cnb.yml` 的 docker.build 直接构建使用，无需推送制品库
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash \
        gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# 工具链体积约 90MB，官方源偶发连接被重置（Recv failure: Connection reset by peer），
# 这里带重试下载并准备官方二级域名作为兜底，避免单次网络抖动导致整条流水线失败。
ARG MOON_MIRROR=https://cli.moonbitlang.com
ARG MOON_MIRROR_FALLBACK=https://cli.moonbitlang.cn

RUN set -eux; \
    download() { \
        curl -fsSL --location \
            --retry 5 --retry-delay 5 --retry-all-errors \
            --connect-timeout 30 --max-time 900 \
            --output "$2" "$1"; \
    }; \
    for base in "$MOON_MIRROR" "$MOON_MIRROR_FALLBACK"; do \
        [ -n "$base" ] || continue; \
        if download "$base/install/unix.sh" /tmp/moon-install.sh; then \
            sed -i "s#^CLI_MOONBIT=.*#CLI_MOONBIT=\"$base\"#" /tmp/moon-install.sh; \
            if bash /tmp/moon-install.sh; then \
                rm -f /tmp/moon-install.sh; \
                exit 0; \
            fi; \
            echo "moonbit install failed via $base, trying next mirror"; \
            rm -rf "$HOME/.moon"; \
        else \
            echo "moonbit install script unavailable at $base, trying next mirror"; \
        fi; \
    done; \
    echo "failed to install moonbit toolchain from any configured mirror" >&2; \
    exit 1

ENV PATH="/root/.moon/bin:${PATH}"

RUN moon version --all
