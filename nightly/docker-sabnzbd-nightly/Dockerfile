FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV HOME="/config" \
TERM="xterm" \
PYTHONIOENCODING=utf-8

RUN \
  echo "**** starting install sabnzbd packages ****" && \
     apk add --no-cache apk-tools jq bash busybox coreutils shadow && \
     apk add -U --update --no-cache --virtual=build-dependencies build-base gcc libffi-dev openssl-dev python3-dev && \
     apk add -U --update --no-cache curl tar p7zip par2cmdline python3 py3-pip && \
     apk add -U --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main unrar && \
  SABNZBD_VERSION=$(curl -fsSL "https://api.github.com/repos/sabnzbd/sabnzbd/commits/develop" | jq -r .sha) && \
  mkdir -p /app/sabnzbd && \
  curl -fsSL "https://github.com/sabnzbd/sabnzbd/archive/${SABNZBD_VERSION}.tar.gz" | tar xzf - -C /app/sabnzbd --strip-components=1 && \
  python3 -m pip install --upgrade pip && \
  pip3 install -U --no-cache-dir \
    wheel \
    apprise \
    pynzb \
    sabyenc3 \
    requests && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine/ -r /app/sabnzbd/requirements.txt && \
  pip3 cache purge && \
  echo "**** cleanup ****" && \
     ln -s /usr/bin/python3 /usr/bin/python && \
     apk del --purge build-dependencies && \
     rm -rf /var/cache/apk/* /tmp/* $HOME/.cache

COPY ./apps/docker-sabnzbd/root/ /

EXPOSE 8080 9090
VOLUME /config
