FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# add repo and install qbitorrent
RUN \
  echo "***** add qbitorrent repositories ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg \
    python3 && \
  curl -s https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/gpg.F8756541ADDA2B7D.key | apt-key add - && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && \
  echo "deb http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb-src http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/deb/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    p7zip-full \
    qbittorrent-cli \
    qbittorrent-nox=${VERSION} \
    unrar \
    geoip-bin \
    unzip && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY ./apps/docker-qbitorrent/root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config
