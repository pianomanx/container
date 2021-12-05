FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

ARG VERSION

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl \
	php7-ctype \
	php7-gd \
	php7-mysqli \
	php7-pdo_pgsql \
	php7-pdo_sqlite && \
 echo "**** install librespeed ****" && \
   LIBRESPEED_RELEASE=$(curl -sX GET "https://api.github.com/repos/librespeed/speedtest/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
   mkdir -p /usr/share/webapps/librespeed && \
   curl -o /tmp/librespeed.tar.gz -L "https://github.com/librespeed/speedtest/archive/${LIBRESPEED_RELEASE}.tar.gz" && \
   tar xf /tmp/librespeed.tar.gz -C /usr/share/webapps/librespeed --strip-components=1 && \
 echo "**** cleanup ****" && \
   rm -rf /tmp/*

COPY ./apps/docker-librespeed/root/ /

EXPOSE 80
VOLUME /config
