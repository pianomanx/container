FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

ARG VERSION
ARG DEBIAN_FRONTEND="noninteractive"
ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

# install software
RUN \
 echo "**** add repositories ****" && \
 apt-get update -yqq && \
 apt-get install -yqq \
	gnupg && \
 apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C5E6A5ED249AD24C && \
 echo "deb http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> \
	/etc/apt/sources.list.d/deluge.list && \
 echo "deb-src http://ppa.launchpad.net/deluge-team/stable/ubuntu focal main" >> \
	/etc/apt/sources.list.d/deluge.list && \
 echo "**** install packages ****" && \
 apt-get update -yqq && \
 apt-get install -yqq \
	deluged \
	deluge-console \
	deluge-web \
	python3-future \
	python3-requests \
	p7zip-full \
	unrar \
	unzip && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY ./apps/docker-deluge/root/ /

# ports and volumes
EXPOSE 8112 58846 58946 58946/udp
VOLUME /config
