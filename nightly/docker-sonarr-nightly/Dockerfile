FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG BRANCH="develop"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN  \
    echo "**** install packages ****" && \
       apk add --no-cache jq curl tar sqlite-libs && \
       apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main tinyxml2 && \
       apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community libmediainfo && \
       apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing mono && \
    echo "**** install sonarr ****" && \
       mkdir -p /app/sonarr/bin && \
       SVERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$BRANCH\") | .version") && \
       curl -fsSL "https://download.sonarr.tv/v3/${BRANCH}/${SVERSION}/Sonarr.${BRANCH}.${SVERSION}.linux.tar.gz" | tar xzf - -C /app/sonarr/bin --strip-components=1 && \
    echo -e "UpdateMethod=docker\nBranch=${BRANCH}\nPackageVersion=${SVERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/sonarr/package_info && \
    echo "**** cleanup ****" && \
       rm -rf /app/sonarr/bin/Sonarr.Update

COPY ./apps/docker-sonarr/root/ /

EXPOSE 8989
VOLUME /config
