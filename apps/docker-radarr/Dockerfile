FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ARG RADARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jq \
    libicu66 \
    libmediainfo0v5 \
    sqlite3 && \
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?runtime=netcore&os=linux" | jq -r '.[0].version') && \
  curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
  tar ixzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/radarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-radarr/root/ /

EXPOSE 7878
VOLUME /config
