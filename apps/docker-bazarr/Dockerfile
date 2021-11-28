FROM ghcr.io/linuxserver/baseimage-alpine:3.14

# set version label
ARG VERSION
# hard set UTC in case the user does not define it
ENV TZ="Etc/UTC"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    g++ \
    gcc \
    jq \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    curl \
    unrar \
    ffmpeg \
    libxml2 \
    libxslt \
    py3-pip \
    python3 \
    unrar \
    unzip

RUN \
  echo "**** install ${VERSION} ****" && \
  curl -o \
    /tmp/bazarr.zip -L \
    "https://github.com/morpheus65535/bazarr/releases/download/v${VERSION}/bazarr.zip"

RUN \
  mkdir -p \
    /app/bazarr/bin && \
  unzip \
    /tmp/bazarr.zip -d \
    /app/bazarr/bin && \
  rm -Rf /app/bazarr/bin/bin && \
  echo "UpdateMethod=docker\nBranch=master\nPackageVersion=${VERSION}\nPackageAuthor=[dockserver.io](https://dockserver.io)" > /app/bazarr/package_info && \
  echo "**** Install requirements ****" && \
  pip3 install -U --no-cache-dir pip && \
  pip install lxml --no-binary :all: && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine/  -r \
    /app/bazarr/bin/requirements.txt && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /root/.cargo \
    /tmp/*

# add local files
COPY ./apps/docker-bazarr/root/ /

# ports and volumes
EXPOSE 6767
VOLUME /config
