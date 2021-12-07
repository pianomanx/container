FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ENV DEBIAN_FRONTEND="noninteractive" \
PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
PLEX_MEDIA_SERVER_USER="abc" \
PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (dockserver.io)"

RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export PLEX_ARCH='amd64'; \
        export EXTRA_ARG='beignet-opencl-icd ocl-icd-libopencl1 i965-va-driver'; \
    ;; \
    'linux/armhf') \
        export PLEX_ARCH='armhf'; \
        export EXTRA_ARG=''; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
    'linux/arm64') \
        export PLEX_ARCH='arm64'; \
        export EXTRA_ARG=''; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
  esac \
  echo "**** install runtime packages ****" && \
  apt-get update -yqq && \
  apt-get install -yqq \
	jq \
	udev \
	unrar \
	wget \
	unzip \
	uuid-runtime \
	${EXTRA_ARG} \
  && \
  case "${PLEX_ARCH}" in \
    'amd64') \
      COMP_RT_RELEASE=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.tag_name') \
      && COMP_RT_URLS=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/tags/${COMP_RT_RELEASE}" | jq -r '.body' | grep wget | sed 's|wget ||g') \
      && mkdir -p /opencl-intel \
      && \
      for i in ${COMP_RT_URLS}; do \
        i=$(echo ${i} | tr -d '\r'); \
        echo "**** downloading ${i} ****"; \
        curl -o "/opencl-intel/$(basename ${i})" \
          -L "${i}"; \
      done \
      && dpkg -i /opencl-intel/*.deb \
      && rm -rf /opencl-intel \
    ;; \
  esac \
  &&
 echo "**** install plex ****" && \
  curl -o /tmp/plexmediaserver.deb -L "${PLEX_DOWNLOAD}/${VERSION}/debian/plexmediaserver_${VERSION}_${PLEX_ARCH}.deb" && \
  dpkg -i /tmp/plexmediaserver.deb && \
 echo "**** ensure abc user's home folder is /app ****" && \
   usermod -d /app abc && \
 echo "**** cleanup ****" && \
   apt-get clean -yqq && \
   rm -rf /etc/default/plexmediaserver \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

COPY ./apps/docker-plex/root/ /
EXPOSE 32400/tcp
VOLUME /config
