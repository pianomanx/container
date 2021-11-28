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
  apk --quiet --no-cache --no-progress add bash curl bc findutils coreutils && \
  rm -rf /var/cache/apk/*

RUN \
  rm -rf /etc/cont-init.d/10-adduser \
  rm -rf /etc/cont-init.d/90-custom-folders \
  rm -rf /etc/cont-init.d/99-custom-files

VOLUME [ "/system" ]
COPY ./apps/docker-mount/root/ /
# Setup EntryPoint
ENTRYPOINT [ "/init" ]
