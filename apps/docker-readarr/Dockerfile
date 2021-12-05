FROM ghcr.io/dockserver/docker-ubuntu-focal:latest

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ARG READARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jq \
    libicu66 \
    sqlite3 && \
  echo "**** install readarr ****" && \
    mkdir -p /app/readarr/bin && \
    READARR_RELEASE=$(curl -sL "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/changes?runtime=netcore&os=linux" | jq -r '.[0].version') && \
  curl -o \
  /tmp/readarr.tar.gz -L \
    "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/updatefile?version=${READARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
  tar ixzf \
  /tmp/readarr.tar.gz -C \
    /app/readarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${READARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/readarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/readarr/bin/Readarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-readarr/root/ /

EXPOSE 8787
VOLUME /config
