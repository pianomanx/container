FROM ghcr.io/linuxserver/baseimage-mono:LTS

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ARG BRANCH="develop"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
   echo "**** install packages ****" && \
      apk add -U --upgrade --no-cache jq curl ca-certificates-mono libmediainfo sqlite-libs && \
   echo "**** install sonarr ****" && \
      mkdir -p /app/sonarr/bin && \
      SONARR=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$BRANCH\") | .version") && \
      curl -o /tmp/sonarr.tar.gz -L "https://download.sonarr.tv/v3/${BRANCH}/${SONARR}/Sonarr.${BRANCH}.${SONARR}.linux.tar.gz" && \
      tar xzf /tmp/sonarr.tar.gz -C /app/sonarr/bin --strip-components=1 && \
   echo "UpdateMethod=docker\nBranch=${BRANCH}\nPackageVersion=${SONARR}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/sonarr/package_info && \
   echo "**** cleanup ****" && \
   rm -rf \
      /app/sonarr/bin/Sonarr.Update \
      /tmp/* \
      /var/tmp/*

COPY ./apps/docker-sonarr/root/ /

EXPOSE 8989
VOLUME /config
