#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################
FROM alpine:3.15
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

RUN \
  echo "**** update build packages ****" \
     apk --quiet --no-cache --no-progress update && \
     apk --quiet --no-cache --no-progress upgrade && \
  echo "**** install build packages ****" && \
     apk add --no-cache --virtual=build-dependencies curl patch tar && \
     bash curl tzdata xz coreutils shadow curl tar jq

RUN \
  OVERLAY=$(curl -sL "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq -r '. | .tag_name') \
  && set -x && ARCH=$(uname -m) \
  && case "${ARCH}" in \
     x86_64) \
        ARCH='amd64' && \
        curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY}/s6-overlay-${ARCH}.tar.gz | tar xvzf - -C / ; \
        ;; \
     armv7) \
        ARCH='arm' && \
        curl -o /usr/bin/qemu-${ARCH}-static -L "https://lsio-ci.ams3.digitaloceanspaces.com/qemu-${ARCH}-static" && \
        chmod +x /usr/bin/qemu-${ARCH}-static && \
        curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY}/s6-overlay-${ARCH}.tar.gz | tar xvzf - -C / ; \
     ;; \
     armhf) \
        ARCH='armhf' && \
        curl -o /usr/bin/qemu-${ARCH}-static -L "https://lsio-ci.ams3.digitaloceanspaces.com/qemu-${ARCH}-static" && \
        chmod +x /usr/bin/qemu-${ARCH}-static && \
        curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY}/s6-overlay-${ARCH}.tar.gz | tar xvzf - -C / ; \
     ;; \
     aarch64) \
        ARCH='aarch64' && \
        curl -o /usr/bin/qemu-${ARCH}-static -L "https://lsio-ci.ams3.digitaloceanspaces.com/qemu-${ARCH}-static" && \
        chmod +x /usr/bin/qemu-${ARCH}-static && \
        curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY}/s6-overlay-${ARCH}.tar.gz | tar xvzf - -C / ; \
      ;; \
     *) echo >&2 "Error: unsupported architecture ($ARCH)"; exit 1 ;; \
  esac \
  && \
  apk del --purge build-dependencies && rm -rf /tmp/* && \
  echo "**** install build packages ****" && \
     apk add --no-cache --virtual=build-dependencies curl patch tar && \
  echo "**** install runtime packages ****" && \
     apk add --no-cache ca-certificates coreutils procps shadow tzdata bash curl bc findutils && \
  echo "**** create abc user and make our folders ****" && \
     groupmod -g 1000 users && \
     useradd -u 911 -U -d /config -s /bin/false abc && \
     usermod -G users abc

VOLUME [ "/system" ]
COPY ./apps/docker-mount/root/ /
ENTRYPOINT [ "/init" ]
