FROM ghcr.io/dockserver/docker-ubuntu-focal:latest

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ARG LIDARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update -yqq && \
  apt-get install --no-install-recommends -y \
    jq \
    libchromaprint-tools \
    libicu60 && \
  echo "**** install lidarr ****" && \
  mkdir -p /app/lidarr/bin && \
  LIDARR_RELEASE=$(curl -sL "https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/changes?runtime=netcore&os=linux" | jq -r '.[0].version') && \
  curl -o \
    /tmp/lidarr.tar.gz -L \
    "https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/updatefile?version=${LIDARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
  tar ixzf \
    /tmp/lidarr.tar.gz -C \
    /app/lidarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${LIDARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/lidarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/lidarr/bin/Lidarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-lidarr/root/ /

EXPOSE 8686
VOLUME /config
