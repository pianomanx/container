ARG VERSION
FROM alpine:${VERSION} as rootfs-stage

# environment
ENV REL=v3.15
ENV ARCH=x86_64
ENV MIRROR=http://dl-cdn.alpinelinux.org/alpine
ENV PACKAGES=alpine-baselayout,\
alpine-keys,\
apk-tools,\
busybox,\
libc-utils,\
xz

ENV PACKAGES=alpine-baselayout,\
alpine-keys,\
apk-tools,\
busybox,\
libc-utils,\
xz

# install packages
RUN \
 apk add --no-cache \
	bash \
	curl \
	tzdata \
	xz

# fetch builder script from gliderlabs
RUN \
 curl -o \
 /mkimage-alpine.bash -L \
	https://raw.githubusercontent.com/gliderlabs/docker-alpine/master/builder/scripts/mkimage-alpine.bash && \
 chmod +x \
	/mkimage-alpine.bash && \
 ./mkimage-alpine.bash  && \
 mkdir /root-out && \
 tar xf \
	/rootfs.tar.xz -C \
	/root-out && \
 sed -i -e 's/^root::/root:!:/' /root-out/etc/shadow

# Runtime stage
FROM scratch
COPY --from=rootfs-stage /root-out/ /
ARG VERSION

# set version for s6 overlay
RUN set -x && apk add --no-cache bash curl coreutils tzdata shadow curl tar jq \
  && OVERLAY_ARCH=$(uname -m) \
  && case "${OVERLAY_ARCH}" in \
    x86_64) OVERLAY_ARCH='amd64';; \
    arm) OVERLAY_ARCH='armhf';; \
    aarch64) OVERLAY_ARCH='aarch64';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && OVERLAY_VERSION=$(curl -sL "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq -r '. | .tag_name') \
  && curl -L -s https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz | tar xvzf - -C / \
  && apk del --no-cache curl && apk del --purge &&  rm -rf /tmp/*

COPY ./base/docker-alpine/patch/ /tmp/patch

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	patch \
	tar && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
	ca-certificates \
	coreutils \
	procps \
	shadow \
	tzdata && \
 echo "**** create abc user and make our folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
 mkdir -p \
	/app \
	/config \
	/defaults && \
 mv /usr/bin/with-contenv /usr/bin/with-contenvb && \
 patch -u /etc/s6/init/init-stage2 -i /tmp/patch/etc/s6/init/init-stage2.patch && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY ./base/docker-alpine/root/ /

ENTRYPOINT ["/init"]
