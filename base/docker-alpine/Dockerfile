FROM alpine:3.15
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

RUN \
  echo "**** install build packages ****" \
  && apk add --no-cache --virtual=build-dependencies tar curl jq \
  && OVERLAY=2.2.0.3 \
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
  echo "**** install runtime packages ****" && \
     apk add --no-cache apk-tools bash busybox coreutils shadow && \
  echo "**** create abc user and make our folders ****" && \
     groupmod -g 1000 users && \
     useradd -u 911 -U -d /config -s /bin/false abc && \
     usermod -G users abc && \
     mkdir -p /{app,config,defaults,system} && \
     rm -rf /var/cache/apk/*

COPY ./base/docker-alpine/root/ /

ENTRYPOINT ["/init"]
