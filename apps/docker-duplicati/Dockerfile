FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ENV HOME="/config"

RUN set -xe && \
  echo "**** install packages ****" && \
     apk add --no-cache unzip jq openssl curl tar sqlite-libs && \
     apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        mono libgdiplus terminus-font && \
  echo "**** install sonarr ****" && \
     mkdir -p /app/duplicati && \
     DVERSION=$(curl -sL "https://api.github.com/repos/duplicati/duplicati/releases" | jq -r 'first(.[] | select(.tag_name | contains("beta"))) | .tag_name') && \
     curl -o /tmp/duplicati.zip -L "$(curl -s https://api.github.com/repos/duplicati/duplicati/releases/tags/${DVERSION} | jq -r '.assets[].browser_download_url' | grep zip | grep -v signatures)" && \
     unzip /tmp/duplicati.zip -d /app/duplicati && \
   echo "**** cleanup ****" && \
     rm -rf /tmp/* /var/tmp/*

COPY ./apps/docker-duplicati/root/ /
EXPOSE 8200
VOLUME /config
