ARG VERSION
FROM ghcr.io/dockserver/docker-alpine:latest as guacbuilder

ARG GUACD_VERSION=1.1.0

RUN \
 echo "**** install build deps ****" && \
 apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	ossp-uuid-dev && \
 apk add --no-cache \
	cairo-dev \
	libjpeg-turbo-dev \
	libpng-dev \
	ffmpeg-dev \
	freerdp-dev \
	openssl-dev \
	pulseaudio-dev \
	libvorbis-dev \	
	libwebp-dev \
	perl \
	cunit-dev \
	autoconf \
	automake \
	alpine-sdk && \
 echo "**** compile guacamole ****" && \
 mkdir /buildout && \
 mkdir /tmp/guac && \
 cd /tmp/guac && \
 wget \
	http://apache.org/dyn/closer.cgi?action=download\&filename=guacamole/${GUACD_VERSION}/source/guacamole-server-${GUACD_VERSION}.tar.gz \
	-O guac.tar.gz && \
 tar -xf guac.tar.gz && \
 cd guacamole-server-${GUACD_VERSION} && \
 ./configure \
	CPPFLAGS="-Wno-deprecated-declarations" \
	--disable-guacenc \
	--disable-guaclog \
	--prefix=/usr \
	--sysconfdir=/etc \
	--mandir=/usr/share/man \
	--localstatedir=/var \
	--enable-static \
	--with-libavcodec \
	--with-libavutil \
	--with-libswscale \
	--with-ssl \
	--without-winsock \
	--with-vorbis \
	--with-pulse \
	--without-pango \
	--without-terminal \
	--without-vnc \
	--with-rdp \
	--without-ssh \
	--without-telnet \
	--with-webp \
	--without-websockets && \
 make && \
 make DESTDIR=/buildout install

ARG VERSION
FROM ghcr.io/dockserver/docker-alpine:latest as nodebuilder
ARG GCLIENT_RELEASE

RUN \
 echo "**** install build deps ****" && \
 apk add --no-cache \
	curl \
	g++ \
	gcc \
	linux-pam-dev \
	make \
	nodejs \
	npm \
	python3 && \
 echo "**** grab source ****" && \
 mkdir -p /gclient && \
 if [ -z ${GCLIENT_RELEASE+x} ]; then \
	GCLIENT_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/gclient/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/gclient.tar.gz -L \
	"https://github.com/linuxserver/gclient/archive/${GCLIENT_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/gclient.tar.gz -C \
	/gclient/ --strip-components=1

RUN \
 echo "**** install node modules ****" && \
 cd /gclient && \
 npm install

# runtime stage
FROM ghcr.io/linuxserver/baseimage-rdesktop:alpine

# Copy build outputs
COPY --from=nodebuilder /gclient /gclient
COPY --from=guacbuilder /buildout /

RUN \ 
 echo "**** install packages ****" && \
 apk add --no-cache \
	ca-certificates \
	font-noto \
	freerdp-libs \
	nodejs \
	openbox && \
 apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	ossp-uuid && \
 apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
	websocat && \
 echo "**** openbox tweaks ****" && \
 sed -i \
	's/NLIMC/NLMC/g' \
	/etc/xdg/openbox/rc.xml && \
 echo "**** cleanup ****" && \
 rm -rf \
        /tm

# add local files
COPY ./apps/docker-gui/root/ /

# ports and volumes
EXPOSE 3000
VOLUME [ "/config" ]
