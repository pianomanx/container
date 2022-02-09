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
FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

RUN \
  echo "**** install runtime packages ****" && \
     apk add --no-cache apk-tools bash busybox coreutils shadow && \
  echo "**** cleanup  ****" && \
     rm -rf /var/cache/apk/*

VOLUME [ "/system" ]
COPY ./apps/docker-uploader/root/ /
ENTRYPOINT [ "/init" ]
