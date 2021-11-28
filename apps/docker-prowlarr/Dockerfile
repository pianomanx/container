FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG VERSION
ARG PROWLARR_RELEASE

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG PROWLARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jq \
    libicu66 \
    sqlite3 && \
  echo "**** install prowlarr ****" && \
  mkdir -p /app/prowlarr/bin && \
  if [ -z ${PROWLARR_RELEASE+x} ]; then \
    PROWLARR_RELEASE=$(curl -sL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/changes?runtime=netcore&os=linux" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/prowlarr.tar.gz -L \
    "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/updatefile?version=${PROWLARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
  tar ixzf \
    /tmp/prowlarr.tar.gz -C \
    /app/prowlarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${PROWLARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/prowlarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/prowlarr/bin/prowlarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# copy local files
COPY ./apps/docker-prowlarr/root/ /

# ports and volumes
EXPOSE 9696
VOLUME /config
