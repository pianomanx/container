FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ENV HOME="/config"

RUN set -xe && \
  echo "**** install packages ****" && \
     apk add --no-cache jq openssl curl tar sqlite-libs && \
     apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        mono libgdiplus terminus-font && \
  echo "**** install sonarr ****" && \
     DUPLICATI_RELEASE=$(curl -sX GET "https://api.github.com/repos/duplicati/duplicati/releases" | jq -r 'first(.[] | select(.tag_name)) | .tag_name') && \
     mkdir -p /app/duplicati && \
     curl -fsSL "https://github.com/duplicati/duplicati/archive/refs/tags/${DUPLICATI_RELEASE}.tar.gz" | tar xzf - -C /app/duplicati --strip-components=1 && \
  echo "**** cleanup ****" && \
     rm -rf /tmp/* /var/tmp/*

COPY ./apps/docker-duplicati/root/ /
EXPOSE 8200
VOLUME /config
