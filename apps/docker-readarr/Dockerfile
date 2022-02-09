FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG READARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN  \
    echo "**** install packages ****" && \
       apk add --no-cache chromaprint jq tar curl libintl sqlite-libs icu-libs && \
    echo "**** install readarr ****" && \
       mkdir -p /app/readarr/bin && \
       READARR_RELEASE=$(curl -sL "https://readarr.servarr.com/v1/update/${BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version') && \
       curl -fsSL "https://readarr.servarr.com/v1/update/nightly/updatefile?version=${READARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=x64" | tar xzf - -C /app/readarr/bin --strip-components=1 && \
    echo "UpdateMethod=docker\nBranch=${READARR_BRANCH}\nPackageVersion=${READARR_RELEASE}\nPackageAuthor=[dockserver.io](https://dockserver.io/)" > /app/readarr/package_info && \
    echo "**** cleanup ****" && \
       rm -rf /app/readarr/bin/Readarr.Update

COPY ./apps/docker-readarr/root/ /

EXPOSE 8787
VOLUME /config
