FROM ghcr.io/linuxserver/baseimage-mono:LTS

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV SONARR_BRANCH="main"

RUN \
  echo "**** install packages ****" && \
  apt-get update -yqq && \
  apt-get install -yqq \
    jq && \
  echo "**** install sonarr ****" && \
    mkdir -p /app/sonarr/bin && \
  SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version") && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
  tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/sonarr/package_info && \
     rm -rf /app/sonarr/bin/Sonarr.Update && \
  echo "**** cleanup ****" && \
    apt-get clean -yqq && \
    rm -rf \
      /tmp/* \
      /var/tmp/*

COPY ./apps/docker-sonarr/root/ /

EXPOSE 8989
VOLUME /config
