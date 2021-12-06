FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic as buildstage

ARG VERSION
ENV DEBIAN_FRONTEND="noninteractive" 

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	cpio \
	jq \
	rpm2cpio && \
 echo "**** install emby ****" && \
 mkdir -p \
	/app/emby && \
 EMBY_RELEASE=$(curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases/latest | jq -r '. | .tag_name') && \
 curl -o \
	/tmp/emby.rpm -L \
	"https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/emby-server-rpm_${EMBY_RELEASE}_x86_64.rpm" && \
 cd /tmp && \
 rpm2cpio emby.rpm \
	| cpio -i --make-directories && \
 mv -t \
	/app/emby/ \
	/tmp/opt/emby-server/system/* \
	/tmp/opt/emby-server/lib/* \
	/tmp/opt/emby-server/bin/ff* \
	/tmp/opt/emby-server/etc \
	/tmp/opt/emby-server/extra/lib/*

FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	mesa-va-drivers && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

COPY --from=buildstage /app/emby /app/emby
COPY ./apps/docker-emby/root/ /

EXPOSE 8096 8920
VOLUME /config
