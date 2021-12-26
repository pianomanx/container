FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic as buildstage

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV DEBIAN_FRONTEND="noninteractive" 

RUN \
  echo "**** set the platform ****" && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
      export ARCH='x86_64'; \
      export EXTRA_INSTALL_ARG='beignet-opencl-icd i965-va-driver ocl-icd-libopencl1'; \
    ;; \
    'linux/arm64') \
      export ARCH='aarch64'; \
      export EXTRA_INSTALL_ARG=''; \
    ;; \
  esac \
  && \
  echo "**** install packages ****" && \
  apt-get update -yqq && \
  apt-get install -yqq \
    aria2 \
    unrar \
    uuid-runtime \
    cpio \
    jq \
    rpm2cpio \
    ${EXTRA_INSTALL_ARG} && \
  echo "**** install emby ****" && \
    mkdir -p /app/emby && \
    curl -o /tmp/emby.rpm -L "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm" && \
    cd /tmp && \
    rpm2cpio emby.rpm | cpio -i --make-directories && \
    printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[dockserver.io](https://dockserver.io)" "${VERSION}" > /app/package_info \
  echo "**** cleanup ****" && \
  mv -t \
    /app/emby \
    /tmp/opt/emby-server/system/* \
    /tmp/opt/emby-server/lib/* \
    /tmp/opt/emby-server/extra/lib/* \
    /tmp/opt/emby-server/bin/ff* \
    /tmp/opt/emby-server/etc

FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG TARGETPLATFORM
ARG VERSION

ENV NVIDIA_DRIVER_CAPABILITIES=""

RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export ARCH='amd64'; \
        export INSTALL_ARG='beignet-opencl-icd i965-va-driver gpg-agent libmfx1 ocl-icd-libopencl1'; \
        export INSTALL_INTEL='intel-opencl-icd intel-level-zero-gpu level-zero intel-media-va-driver-non-free'; \
        export NVIDIA_DRIVER_CAPABILITIES='compute,video,utility'; \
    ;; \
   'linux/arm64') \
        export INSTALL_ARG=''; \
        export INSTALL_INTEL=''; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
    ;; \
    'linux/armhf') \
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
    mesa-va-drivers \
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
  echo "**** install packages ****" && \
    apt-get purge -yqq --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get autoremove -yqq && apt-get clean && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

COPY --from=buildstage /app/emby /app/emby
COPY ./apps/docker-emby/root/ /

EXPOSE 8096 8920
VOLUME /config
