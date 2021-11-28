#####################################
# Original coder PhysK              #
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
ARG VERSION
FROM ghcr.io/linuxserver/baseimage-alpine:${VERSION}
LABEL maintainer=dockserver

RUN \
  echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add shadow bash findutils coreutils && \
  rm -rf /var/cache/apk/* && rm -rf /tmp/*

VOLUME [ "/system" ]

COPY ./apps/docker-uploader/root/ /

# Setup EntryPoint
ENTRYPOINT [ "/init" ]
