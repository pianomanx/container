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
RUN \
 echo "**** update build packages ****" && \
   apk --quiet --no-cache --no-progress update && \
   apk --quiet --no-cache --no-progress upgrade && \
 echo "**** install build packages ****" && \
   apk add --quiet --no-cache --no-progress bash curl tzdata xz coreutils musl \
  fuse3 fuse3-dev shadow curl tar jq

VOLUME [ "/system" ]
COPY ./apps/docker-mount/root/ /
ENTRYPOINT [ "/init" ]
