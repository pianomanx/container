#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION

FROM rclone/rclone:${VERSION}

RUN \
    echo "**** install build packages ****" && \
    apk --quiet --no-cache --no-progress update && \
    apk --quiet --no-cache --no-progress upgrade
RUN \
    echo "**** install build packages ****" && \
    apk --quiet --no-cache --no-progress add bash musl && \
    apk del --quiet --clean-protected --no-progress && \
    rm -f /var/cache/apk/*


COPY ./apps/docker-rclone/root/ /

ENTRYPOINT [ "/bin/bash", "/start.sh" ]
