#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION
FROM alpine:${VERSION}

LABEL maintainer=dockserver
RUN \
    apk add --no-cache \
        bash

COPY ./apps/dockupdate/root/start.sh /start.sh
ENTRYPOINT [ "/bin/bash", "/start.sh" ]
