# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
ARG VERSION

FROM haproxy:${VERSION}

EXPOSE 2375

RUN \
  apk add --no-cache curl && \
  curl -o \
  /usr/local/etc/haproxy/haproxy.cfg -L \
  "https://raw.githubusercontent.com/Tecnativa/docker-socket-proxy/master/haproxy.cfg"

ENV ALLOW_RESTARTS=0 \
    AUTH=0 \
    BUILD=0 \
    COMMIT=0 \
    CONFIGS=0 \
    CONTAINERS=0 \
    DISTRIBUTION=0 \
    EVENTS=1 \
    EXEC=0 \
    GRPC=0 \
    IMAGES=0 \
    INFO=0 \
    LOG_LEVEL=info \
    NETWORKS=0 \
    NODES=0 \
    PING=1 \
    PLUGINS=0 \
    POST=0 \
    SECRETS=0 \
    SERVICES=0 \
    SESSION=0 \
    SOCKET_PATH=/var/run/docker.sock \
    SWARM=0 \
    SYSTEM=0 \
    TASKS=0 \
    VERSION=1 \
    VOLUMES=0

##COPY ./base/docker-haproxy/root/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
