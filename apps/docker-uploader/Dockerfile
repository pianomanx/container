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
FROM docker.dockserver.io/dockserver/docker-alpine:latest
VOLUME [ "/system" ]
COPY ./apps/docker-uploader/root/ /
ENTRYPOINT [ "/init" ]
