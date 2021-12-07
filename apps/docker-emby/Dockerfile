FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic as buildstage

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV DEBIAN_FRONTEND="noninteractive" 

RUN \
  echo "**** set the platform ****" \
  && \
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
  printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info \
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

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    INTEL_NEO_VERSION=21.48.21782 \
    INTEL_IGC_VERSION=1.0.9441 \
    INTEL_GMMLIB_VERSION=21.3.3
RUN \
  apt-get update -yqq && \
  apt-get install -yqq --no-install-recommends mesa-va-drivers uuid-runtime && \
  case "${ARCH}" in \
    'x86_64') \
      curl -J -L -o /tmp/gmmlib.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-gmmlib_${INTEL_GMMLIB_VERSION}_amd64.deb \
      && apt-get install -y /tmp/gmmlib.deb \
      && curl -J -L -o /tmp/#1.deb https://github.com/intel/intel-graphics-compiler/releases/download/igc-${INTEL_IGC_VERSION}/{intel-igc-core,intel-igc-opencl}_${INTEL_IGC_VERSION}_amd64.deb \
      && apt-get install -y /tmp/intel-igc-core.deb /tmp/intel-igc-opencl.deb \
      && curl -J -L -o /tmp/intel-opencl.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-opencl_${INTEL_NEO_VERSION}_amd64.deb \
      && apt-get install -y /tmp/intel-opencl.deb \
    ;; \
    'arm64') \
      unset NVIDIA_DRIVER_CAPABILITIES; \
      unset INTEL_NEO_VERSION; \
      unset INTEL_IGC_VERSION; \
      unset INTEL_GMMLIB_VERSION; \
    ;; \
  esac \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

COPY --from=buildstage /app/emby /app/emby
COPY ./apps/docker-emby/root/ /

EXPOSE 8096 8920
VOLUME /config
