FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN  \
    echo "**** install packages ****" && \
       apk add --no-cache jq openssl curl tar icu-libs sqlite-libs && \
       apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main tinyxml2 && \
       apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community libmediainfo && \
    echo "**** install radarr ****" && \
       mkdir -p /app/radarr/bin && \
       RADARR=$(curl -sL "https://radarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
       curl -fsSL "https://radarr.servarr.com/v1/update/${BRANCH}/updatefile?version=${RADARR}&os=linuxmusl&runtime=netcore&arch=x64" | tar xzf - -C /app/radarr/bin --strip-components=1 && \
    echo -e "UpdateMethod=docker\nBranch=${BRANCH}\nPackageVersion=${RADARR}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/radarr/package_info && \
    echo "**** cleanup ****" && \
    rm -rf /app/radarr/bin/Radarr.Update 

COPY ./apps/docker-radarr/root/ /

EXPOSE 7878
VOLUME /config
