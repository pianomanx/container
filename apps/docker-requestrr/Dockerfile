FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    libicu66 unzip && \
  echo "**** install requestrr ****" && \
  mkdir -p /app/requestrr/bin && \
  REQUESTRR_RELEASE=$(curl -sX GET "https://api.github.com/repos/darkalfx/requestrr/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o \
    /tmp/requestrr.zip -L \
    "https://github.com/darkalfx/requestrr/releases/download/${REQUESTRR_RELEASE}/requestrr-linux-x64.zip" && \
  unzip \
    /tmp/requestrr.zip -d \
    /tmp/requestrr && \
  mv \
      /tmp/requestrr/requestrr-linux-x64/* \
      /app/requestrr/bin/ && \
  chmod +x /app/requestrr/bin/Requestrr.WebApi && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-requestrr/root/ /

EXPOSE 4545
VOLUME /config
