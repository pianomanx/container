FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

RUN \
 echo "**** install packages ****" && \
 apt-get update -yqq && \
 apt-get install -yqq \
	jq \
	libicu60 && \
 echo "**** install jackett ****" && \
 mkdir -p /app/Jackett && \
 JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" | jq -r .tag_name) && \
 curl -o \
 /tmp/jacket.tar.gz -L \
	"https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxAMDx64.tar.gz" && \
 tar xf \
 /tmp/jacket.tar.gz -C \
	/app/Jackett --strip-components=1 && \
 echo "**** fix for host id mapping error ****" && \
   chown -R root:root /app/Jackett && \
 echo "**** save docker image version ****" && \
   echo "${VERSION}" > /etc/docker-image && \
 echo "**** cleanup ****" && \
 apt-get clean -yqq && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/* \
	/var/log/*

COPY ./apps/docker-jackett/root/ /
VOLUME /config
EXPOSE 9117
