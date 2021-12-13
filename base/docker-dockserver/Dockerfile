# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION
FROM alpine:${VERSION}

RUN apk add --no-cache bash git

COPY ./apps/docker-dockserverupdate/root/start.sh /start.sh

ENTRYPOINT [ "/bin/bash", "/start.sh" ]
