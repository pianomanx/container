FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG RADARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
   echo "**** install packages ****" && \
      apk add --no-cache tar aria2 curl jq icu-libs sqlite-libs && \
   echo "**** install radarr ****" && \
   mkdir -p /app/radarr/bin && \
   aria2c -x2 -k1M -d /tmp -o radarr.tar.gz https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=x64 && \
   tar ixzf \
     /tmp/radarr.tar.gz -C \
     /app/radarr/bin --strip-components=1 && \
   echo "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/radarr/package_info && \
   echo "**** cleanup ****" && \
   rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/tmp/*

COPY ./apps/docker-radarr/root/ /

EXPOSE 7878
VOLUME /config
