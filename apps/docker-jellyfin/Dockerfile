FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export ARCH='amd64'; \
        export EXTRA_INSTALL_ARG='beignet-opencl-icd intel-media-va-driver-non-free i965-va-driver ocl-icd-libopencl1'; \
    ;; \
    'linux/arm64') \
        export ARCH='arm64'; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
  esac \
  && \
  echo "**** install packages ****" \
  && apt-get update -yqq && apt-get install -yqq --no-install-recommend gnupg \
  && echo "**** install jellyfin *****" \
  && curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - \
  && echo 'deb [arch=${ARCH}] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list \
  && curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
  && echo 'deb [arch=${ARCH}] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list

RUN \
  if [ -z ${VERSION} ]; then \
    JELLYFIN="jellyfin-server"; \
  else \
    JELLYFIN="jellyfin-server=${VERSION}"; \
  fi && \
  apt-get update -yqq && \
  apt-get install -yqq --no-install-recommends \
    at \
    intel-media-va-driver-non-free \
    ${JELLYFIN} \
    jellyfin-ffmpeg \
    jellyfin-web \
    libfontconfig1 \
    libfreetype6 \
    libssl1.1 \
    mesa-va-drivers && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY ./apps/docker-jellyfin/root/ / 

EXPOSE 8096 8920
VOLUME /config
