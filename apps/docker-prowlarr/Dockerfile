FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG PROWLARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN  \
    echo "**** install packages ****" && \
       apk add --no-cache jq curl tar sqlite-libs libintl icu-libs && \
   echo "**** install prowlarr ****" && \
       mkdir -p /app/prowlarr/bin && \
       PROWLARR=$(curl -sL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
       curl -fsSL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/updatefile?version=${PROWLARR}&os=linuxmusl&runtime=netcore&arch=x64" | tar xzf - -C /app/prowlarr/bin --strip-components=1 && \
   echo -e "UpdateMethod=docker\nBranch=${PROWLARR_BRANCH}\nPackageVersion=${PROWLARR}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/prowlarr/package_info && \
   echo "**** cleanup ****" && \
       rm -rf /app/prowlarr/bin/prowlarr.Update

COPY ./apps/docker-prowlarr/root/ /
EXPOSE 9696
VOLUME /config
