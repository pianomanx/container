# hadolint ignore=DL3007
FROM ghcr.io/linuxserver/baseimage-ubuntu:latest as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# hadolint ignore=DL3008,DL3015
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    libglib2.0-0 \
    libglu1-mesa \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='x86_64' ;; \
  esac \
  && \
  curl -fsSL -o /tmp/hyperhdr.deb \
    "https://github.com/awawa-dev/HyperHDR/releases/download/v${VERSION}/HyperHDR-${VERSION}-Linux-${ARCH}.deb" \
  && apt-get install -y /tmp/hyperhdr.deb \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# hadolint ignore=DL3002
USER abc

# add local files
COPY ./apps/docker-hyperhdr/root/ /

EXPOSE 8090 19444 19445
VOLUME /config
