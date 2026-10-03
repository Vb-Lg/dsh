# syntax=docker/dockerfile:1.4
FROM node:22.23.3-trixie-slim AS base

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        util-linux \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data/dsh
ARG DSH_VERSION=latest

# Cache npm downloads between builds when using BuildKit.
RUN --mount=type=cache,target=/root/.npm \
    npm install -g @deepseek-ai/dsh@${DSH_VERSION} \
    && npm cache clean --force \
    && dsh --version

FROM node:22.23.3-trixie-slim AS runtime

# Ensure runtime has the minimal required system dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        util-linux \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data/dsh

COPY --from=base /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=base /usr/local/bin /usr/local/bin

ENV TRUSTED_HOST=dsh.vblg.top \
    NO_COLOR=1 \
    CI=true \
    NODE_OPTIONS=--no-warnings

EXPOSE 27593

ENTRYPOINT ["dsh"]
CMD ["--profile", "web", "--no-open", "--port", "27593", "--trusted-host", "dsh.vblg.top"]
