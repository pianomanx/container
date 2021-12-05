FROM ghcr.io/linuxserver/baseimage-mono:LTS

ARG VERSION
ENV HOME="/config"

RUN \
 echo "**** install jq ****" && \
 apt-get update -yqq && \
 apt-get install -yqq \
	jq && \
 echo "**** install duplicati ****" && \
 DUPLICATI_RELEASE=$(curl -sX GET "https://api.github.com/repos/duplicati/duplicati/releases" \
	| jq -r 'first(.[] | select(.tag_name)) | .tag_name') && \
 mkdir -p \
	/app/duplicati && \
  duplicati_url=$(curl -s https://api.github.com/repos/duplicati/duplicati/releases/tags/"${DUPLICATI_RELEASE}" |jq -r '.assets[].browser_download_url' |grep zip |grep -v signatures) && \
 curl -o \
 /tmp/duplicati.zip -L \
	"${duplicati_url}" && \
 unzip -q /tmp/duplicati.zip -d /app/duplicati && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

COPY ./apps/docker-duplicati/root/ /
EXPOSE 8200
VOLUME /mnt/downloads/backups /config /source
