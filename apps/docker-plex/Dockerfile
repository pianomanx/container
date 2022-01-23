FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    DEBIAN_FRONTEND="noninteractive" \
    PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_USER="abc" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (dockserver.io)"

# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export ARCH='amd64'; \
        export INSTALL_ARG='beignet-opencl-icd i965-va-driver gpg-agent libmfx1 ocl-icd-libopencl1'; \
        export INSTALL_INTEL='intel-opencl-icd intel-level-zero-gpu level-zero intel-media-va-driver-non-free'; \
    ;; \
    'linux/arm64') \
        export ARCH='arm64'; \
        export INSTALL_ARG=''; \
        export INSTALL_INTEL=''; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
  esac \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    aria2 \
    jq \
    unrar \
    unzip \
    uuid-runtime \
    ${INSTALL_ARG} \
  && \
  case "${ARCH}" in \
    'amd64') \
      COMP_RT_RELEASE=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.tag_name') \
      && COMP_RT_URLS=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/tags/${COMP_RT_RELEASE}" | jq -r '.body' | grep wget | sed 's|wget ||g') \
      && mkdir -p /opencl-intel \
      && \
      for i in ${COMP_RT_URLS}; do \
        i=$(echo ${i} | tr -d '\r'); \
        echo "**** downloading ${i} ****"; \
        curl -o "/opencl-intel/$(basename ${i})" -L "${i}"; \
      done \
      && dpkg -i /opencl-intel/*.deb \
      && rm -rf /opencl-intel \
      && apt-get install -qq gpg-agent wget software-properties-common -y \
      && wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
      && apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' \
      && apt-get -qq update \
      && apt-get -qq install -y ${INSTALL_INTEL} \
      && apt-add-repository -r 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' \
      && apt-get -qq update \
    ;; \
  esac \
  && \
  echo "Using curl or wget to download the plex debian package result in a qemu failure, why? I dunno" \
  && \
  aria2c -d /tmp -o plex.deb "${PLEX_DOWNLOAD}/${VERSION}/debian/plexmediaserver_${VERSION}_${ARCH}.deb" \
  && \
  dpkg -i --force-confold /tmp/plex.deb \
  && \
  apt-get remove -yqq aria2 jq software-properties-common gpg-agent \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -yqq \
  && apt-get clean -yqq \
  && \
  rm -rf \
    /etc/default/plexmediaserver \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chown -R ${PLEX_MEDIA_SERVER_USER}:${PLEX_MEDIA_SERVER_USER} "${PLEX_MEDIA_SERVER_HOME}" \
  && chmod -R u=rwX,go=rX "${PLEX_MEDIA_SERVER_HOME}" \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc

COPY ./apps/docker-plex/root/ /
EXPOSE 32400/tcp
VOLUME /config
