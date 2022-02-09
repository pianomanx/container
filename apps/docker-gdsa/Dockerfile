#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine

ARG VERSION

RUN \
 echo "**** update build packages ****" && \
   apk --quiet --no-cache --no-progress update && \
   apk --quiet --no-cache --no-progress upgrade && \
 echo "**** install build packages ****" && \
   apk --quiet --no-cache --no-progress add bash curl shadow musl findutils coreutils && \
   apk del --quiet --clean-protected --no-progress && \
   rm -f /var/cache/apk/*

COPY ./apps/docker-gdsa/root/ /

ENTRYPOINT [ "/bin/bash", "/movestart.sh" ]
