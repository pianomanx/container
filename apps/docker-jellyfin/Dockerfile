FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN \
  apt-get update -yqq && \
  apt-get install -y --no-install-recommends gnupg curl && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export ARCH='amd64'; \
    ;; \
    'linux/arm64') \
        export ARCH='arm64'; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
  esac \
  && \
  case "${ARCH}" in \
    'amd64') \
        export EXTRA_INSTALL_ARG='beignet-opencl-icd intel-media-va-driver-non-free i965-va-driver ocl-icd-libopencl1' \
        && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
        && echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list \
        && curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
        && echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list \
    ;; \
    'arm64') \
        export EXTRA_INSTALL_ARG='' \
        && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
        && curl -s https://keyserver.ubuntu.com/pks/lookup?op=get\&search=0x6587ffd6536b8826e88a62547876ae518cbcf2f2 | apt-key add - \
        && echo 'deb [arch=arm64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list \
        && echo "deb http://ppa.launchpad.net/ubuntu-raspi2/ppa-nightly/ubuntu focal main">> /etc/apt/sources.list.d/raspbins.list \
    ;; \
  esac \
  && \
  if [ -z ${JELLYFIN_RELEASE+x} ]; then \
    JELLYFIN="jellyfin-server"; \
  else \
    JELLYFIN="jellyfin-server=${VERSION}"; \
  fi && \
  apt-get update -yqq && \
  apt-get install -y --no-install-recommends \
    at \
    intel-media-va-driver-non-free \
    ${JELLYFIN} \
    jellyfin-ffmpeg \
    jellyfin-web \
    libfontconfig1 \
    libfreetype6 \
    libssl1.1 \
    mesa-va-drivers \
    ${EXTRA_INSTALL_ARG} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-jellyfin/root/ / 

EXPOSE 8096 8920
VOLUME /config
