FROM node:22.23.3-trixie-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash \
      coreutils \
      util-linux \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /data/dsh
ARG DSH_VERSION=latest
RUN npm install -g @deepseek-ai/dsh@${DSH_VERSION} \
 && npm cache clean --force \
 && dsh --version
ENV TRUSTED_HOST=dsh.vblg.top
ENV NO_COLOR=1
ENV CI=true
ENV NODE_OPTIONS=--no-warnings
EXPOSE 27593
CMD ["bash", "-lc", "script -qfc \"stdbuf -oL -eL dsh --profile web --no-open --port 27593 --trusted-host ${TRUSTED_HOST} 2>&1\" /dev/null"]
