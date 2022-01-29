FROM alpine:3.15
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG OVERLAY=v2.2.0.3

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/config" \
TERM="xterm" \
PYTHONIOENCODING=utf-8

RUN \
  echo "**** install build packages ****" \
  && apk add --no-cache --virtual=build-dependencies tar curl jq \
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
  echo "**** starting install sabnzbd packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    build-base \
    gcc \
    libffi-dev \
    openssl-dev \
    python3-dev && \
  apk add  -U --update --no-cache \
    curl \
    tar \
    p7zip \
    par2cmdline \
    python3 \
    py3-pip && \
  apk add -U --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main unrar && \
  SABNZBD_VERSION=$(curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  mkdir -p /app/sabnzbd && \
  curl -o \
    /tmp/sabnzbd.tar.gz -L \
    "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" && \
  tar xf \
    /tmp/sabnzbd.tar.gz -C \
    /app/sabnzbd --strip-components=1 && \
  cd /app/sabnzbd && \
  python3 -m pip install --upgrade pip && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine/ \
    wheel \
    apprise \
    pynzb \
    requests && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine/ -r requirements.txt && \
  pip3 cache purge && \
  echo "**** cleanup ****" && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  apk del --purge build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

COPY ./apps/docker-sabnzbd/root/ /

EXPOSE 8080 9090
VOLUME /config
