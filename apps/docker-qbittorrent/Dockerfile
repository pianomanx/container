FROM ghcr.io/dockserver/docker-ubuntu-focal:latest

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

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
  echo "deb https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/deb/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "**** install packages ****" && \
     QBVERSION=$(curl -sX GET http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/focal/main/binary-amd64/Packages.gz | gunzip -c \
     |grep -A 7 -m 1 "Package: qbittorrent-nox" | awk -F ": " '/Version/{print $2;exit}') && \
  apt-get update && \
  apt-get install -y \
    p7zip-full \
    qbittorrent-cli \
    qbittorrent-nox=${QBVERSION} \
    unrar \
    geoip-bin \
    unzip && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-qbittorrent/root/ /

EXPOSE 6881 6881/udp 8080
VOLUME /config
