FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG SONARR_BRANCH="develop"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
   echo "**** install packages ****" && \
      apk add -U --upgrade --no-cache jq curl ca-certificates-mono libmediainfo sqlite-libs && \
   echo "**** install sonarr ****" && \
   mkdir -p /app/sonarr/bin && \
   SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version") && \
   curl -o /tmp/sonarr.tar.gz -L "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
   tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
   echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${SONARR_VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/sonarr/package_info && \
   echo "**** cleanup ****" && \
   rm -rf \
      /app/sonarr/bin/Sonarr.Update \
      /tmp/* \
      /var/tmp/*

COPY ./apps/docker-sonarr/root/ /

EXPOSE 8989
VOLUME /config
