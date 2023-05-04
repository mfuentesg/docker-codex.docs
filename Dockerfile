FROM ghcr.io/linuxserver/baseimage-alpine:arm64v8-3.16 as build
WORKDIR /usr/src/app

RUN CODEX_RELEASE=$(curl -sX GET "https://api.github.com/repos/codex-team/codex.docs/releases/latest" | jq -r '.tag_name') && \
  curl -o /tmp/codex.tar.gz -L "https://github.com/codex-team/codex.docs/archive/refs/tags/${CODEX_RELEASE}.tar.gz" && \
  apk add -U --update --no-cache \
    fontconfig \
    font-noto \
    netcat-openbsd \
    nodejs && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    build-base \
    g++ \
    gcc \
    git \
    icu-libs \
    npm \
    openssl-dev \
    python3-dev \
    sqlite-dev \
    yarn && tar xf /tmp/codex.tar.gz -C /usr/src/app --strip-components=1 && \
    yarn install --production && cp -R node_modules prod_node_modules && \
    yarn install && yarn build-all && yarn cache clean && rm -rf node_modules && mv prod_node_modules node_modules

EXPOSE 3000
ENV NODE_ENV=production
COPY root/ /
CMD ["node", "dist/backend/app.js"]
