FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

ARG VERSION
ENV LIBREDLURL="https://github.com/librespeed/speedtest/archive" \
    LIBREAPI="https://api.github.com/repos/librespeed/speedtest/releases/latest" 

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	aria2 \
	curl \
	php7-ctype \
	php7-gd \
	php7-mysqli \
	php7-pdo_pgsql \
	php7-pdo_sqlite && \
 apk add --no-cache --virtual=build-dependencies aria2 && \
 echo "**** install librespeed ****" && \
   RELEASE=$(curl -sX GET "${LIBREAPI}" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
   mkdir -p /usr/share/webapps/librespeed && \
   aria2c -d /tmp -o librespeed.tar.gz "${LIBREDLURL}/${RELEASE}.tar.gz" && \
   tar xf /tmp/librespeed.tar.gz -C /usr/share/webapps/librespeed --strip-components=1 && \
 echo "**** cleanup ****" && \
   apk del --purge build-dependencies && \
   rm -rf \
      /root/.cache \
      /tmp/*

COPY ./apps/docker-librespeed/root/ /

EXPOSE 80
VOLUME /config
