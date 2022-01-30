FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config" \
    QBT_WEBUI_PORT=8080 \
    LAN=192.168.0.0/16 \
    DOCKER_CIDR=172.17.0.0/16 \
    DNS=1.1.1.1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN set -xe && \
    echo "**** install build packages ****" && \
       apk add --no-cache --virtual=build-dependencies libcap && \
    echo "**** install runtime packages ****" && \
       apk add --no-cache tar iptables jq curl tar subversion sudo && \
    echo "**** install qbittorrent ****" && \
       QVERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp && \
       awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://') && \
       apk add --no-cache qbittorrent-nox=="${QVERSION}" --repository http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    echo "abc ALL=(ALL) NOPASSWD: /sbin/ip" >>/etc/sudoers && \
    echo "**** cleanup ****" && \
       apk del --purge build-dependencies && \
    rm -rf /tmp/*

COPY ./apps/docker-qbittorrent/root/ /

EXPOSE 6881 6881/udp 8080
VOLUME /config
