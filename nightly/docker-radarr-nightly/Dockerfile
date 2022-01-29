FROM ghcr.io/dockserver/docker-alpine:latest

ARG VERSION
ARG RADARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
   echo "**** install packages ****" && \
      apk add -U --upgrade --no-cache jq tar curl shadow icu-libs sqlite-libs && \
   echo "**** install radarr ****" && \
      mkdir -p /app/radarr/bin && \
   if [ -z ${VERSION+x} ]; then \
      VERSION=$(curl -sL "https://radarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version'); \
   fi && \
      curl -o /tmp/radarr.tar.gz -L "https://radarr.servarr.com/v1/update/${BRANCH}/updatefile?version=${VERSION}&os=linuxmusl&runtime=netcore&arch=x64" && \
      tar xzf /tmp/radarr.tar.gz -C /app/radarr/bin --strip-components=1 && \
   echo "**** swt version of Radarr and UpdateMethod****" && \
   echo "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/radarr/package_info && \
      echo "**** cleanup ****" && \
   rm -rf \
      /app/radarr/bin/Radarr.Update \
      /tmp/* \
      /var/tmp/*

COPY ./apps/docker-radarr/root/ /

EXPOSE 7878
VOLUME /config
