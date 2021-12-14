# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION
FROM alpine:${VERSION}

RUN apk add --no-cache bash shadow && \
    usermod -u 1000 abc && \
    groupmod -g 1000 abc

COPY ./base/docker-dockserver/root/start.sh /start.sh

ENTRYPOINT [ "/bin/bash", "/start.sh" ]
