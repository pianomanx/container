FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ENV HOME="/config"

RUN \
 apt-get update -yqq && \
 apt-get install -yqq \
	jq \
	libicu60 \
	libssl1.0 \
	unzip && \
 echo "**** install embystat ****" && \
 mkdir -p /opt/embystat && \
 EMBYSTAT_RELEASE=$(curl -sX GET "https://api.github.com/repos/mregni/EmbyStat/releases" | jq -r 'first(.[] | .tag_name)') && \
 curl -o \
 /tmp/embystat.zip -L \
	"https://github.com/mregni/EmbyStat/releases/download/${EMBYSTAT_RELEASE}/EmbyStat-ubuntu-x64-v${EMBYSTAT_RELEASE}.zip" && \
 unzip /tmp/embystat.zip -d /opt/embystat/ 2> /dev/null || true && \
 chmod +x /opt/embystat/EmbyStat && \
 echo "**** clean up ****" && \
 rm -rf /tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY ./apps/docker-embystat/root/ /

# ports and volumes
EXPOSE 6555
