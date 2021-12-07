#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:${VERSION}-alpine
RUN \
 echo "**** install build packages ****" && \
   apk --quiet --no-cache --no-progress update && \
   apk --quiet --no-cache --no-progress upgrade && \
 echo "**** install build packages ****" && \
  apk --quiet --no-cache --no-progress add bash curl shadow musl findutils coreutils && \
  apk del --quiet --clean-protected --no-progress && \
    rm -f /var/cache/apk/*

COPY ./apps/docker-gdsa/root/ /
ENTRYPOINT [ "/bin/bash", "/start.sh" ]
