FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# environment settings
ARG BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
    apk add -U --upgrade --no-cache jq tar icu-libs sqlite-libs && \
  echo "**** install radarr ****" && \
    mkdir -p /app/radarr/bin && \
  RADARR=$(curl -sL "https://radarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
  curl -o /tmp/radarr.tar.gz -L "https://radarr.servarr.com/v1/update/${BRANCH}/updatefile?version=${RADARR}&os=linuxmusl&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${BRANCH}\nPackageVersion=${RADARR}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/radarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/tmp/

COPY ./apps/docker-radarr/root/ /

EXPOSE 7878
VOLUME /config
