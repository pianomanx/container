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
FROM ghcr.io/dockserver/docker-alpine:v${VERSION}
VOLUME [ "/system" ]
COPY ./apps/docker-mount/root/ /
ENTRYPOINT [ "/init" ]
