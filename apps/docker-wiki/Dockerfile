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

FROM alpine:3.15.0 as buildstage
RUN \
   echo "**** install packages ****" && \
   apk add --update --no-cache git && \
   mkdir -p /tmp && git clone --quiet https://github.com/dockserver/dockserver.git /tmp && \

FROM ghcr.io/squidfunk/mkdocs-material:${VERSION}

LABEL maintainer=dockserver

COPY --from=buildstage /tmp/wiki /docs

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-warn-script-location --upgrade --force-reinstall --no-deps --user -r /docs/requirements.txt

RUN rm -rf /tmp/* && rm -rf /var/cache/apk/* && rm -rf /root/.cache

WORKDIR /docs

EXPOSE 8000
ENTRYPOINT ["mkdocs"]
CMD [ "serve" , "--dev-addr=0.0.0.0:8000" ]
