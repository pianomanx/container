FROM alpine:3.15
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG OVERLAY=v2.2.0.3

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/config" \
TERM="xterm"

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
  apk del --purge build-dependencies && rm -rf /tmp/*

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    curl \
    g++ \
    jq \
    make \
    python3 && \
  echo "**** symlink python3 for compatibility ****" && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    yarn && \
  if [ -z ${OVERSEERR_VERSION+x} ]; then \
    OVERSEERR_VERSION=$(curl -sX GET "https://api.github.com/repos/sct/overseerr/commits?sha=develop" \
      | jq -r 'first(.[] | select(.commit.message | contains("[skip ci]") | not)) | .sha'); \
  fi && \
  export COMMIT_TAG="${OVERSEERR_VERSION}" && \
  curl -o \
    /tmp/overseerr.tar.gz -L \
    "https://github.com/sct/overseerr/archive/${OVERSEERR_VERSION}.tar.gz" && \
  mkdir -p /app/overseerr && \
  tar xzf \
    /tmp/overseerr.tar.gz -C \
    /app/overseerr/ --strip-components=1 && \
  cd /app/overseerr && \
  export NODE_OPTIONS=--max_old_space_size=2048 && \
  yarn --frozen-lockfile --network-timeout 1000000 && \
  yarn build && \
  yarn install --production --ignore-scripts --prefer-offline && \
  yarn cache clean && \
  rm -rf \
    /app/overseerr/src \
    /app/overseerr/server && \
  echo "{\"commitTag\": \"${COMMIT_TAG}\"}" > committag.json && \
  rm -rf /app/overseerr/config && \
  ln -s /config /app/overseerr/config && \
  touch /config/DOCKER && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/* \
    /app/overseerr/.next/cache/*

# copy local files
COPY ./nightly/docker-overseerr-nightly/root/ /

# ports and volumes
EXPOSE 5055

VOLUME /config
