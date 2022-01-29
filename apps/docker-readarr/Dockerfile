FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG READARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
    apk add -U --upgrade --no-cache chromaprint jq icu-libs sqlite-libs && \
  echo "**** install readarr ****" && \
    mkdir -p /app/readarr/bin && \
    READARR_RELEASE=$(curl -sL "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
    curl -fsSL "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/updatefile?version=${READARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=x64" | tar xzf - -C /app/readarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${READARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/readarr/package_info && \
  echo "**** cleanup ****" && \
    rm -rf /app/readarr/bin/Readarr.Update

COPY ./apps/docker-readarr/root/ /

EXPOSE 8787
VOLUME /config
