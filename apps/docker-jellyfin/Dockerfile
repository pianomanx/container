FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
  echo "**** install packages ****" && \
    apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends \
      gnupg \
      curl && \
  echo "**** install jellyfin *****" && \
    curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
  echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list && \
    curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - && \
  echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list && \
  apt-get update -yqq && \
  apt-get install -y --no-install-recommends \
    at \
    jellyfin-server \
    jellyfin-ffmpeg \
    jellyfin-web \
    libfontconfig1 \
    libfreetype6 \
    libssl1.1 \
    intel-media-va-driver-non-free \
    fonts-noto-cjk-extra \
    mesa-va-drivers && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-jellyfin/root/ / 

EXPOSE 8096 8920
VOLUME /config
