FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG LIDARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
    apk add -U --upgrade --no-cache jq tar curl chromaprint icu-libs sqlite-libs && \
  echo "**** install lidarr ****" && \
    mkdir -p /app/lidarr/bin && \
    LIDARR_RELEASE=$(curl -sL "https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
    curl -fsSL "https://lidarr.servarr.com/v1/update/${LIDARR_BRANCH}/updatefile?version=${LIDARR_RELEASE}&os=linux&runtime=netcore&arch=x64" | tar xzf - -C /app/lidarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${LIDARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/lidarr/package_info && \
  echo "**** cleanup ****" && \
    rm -rf \
       /app/lidarr/bin/Lidarr.Update \
       /app/lidarr/bin/fpcalc


COPY ./apps/docker-lidarr/root/ /

EXPOSE 8686
VOLUME /config
