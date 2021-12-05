FROM ghcr.io/dockserver/docker-ubuntu-focal:latest
ARG VERSION

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
ENV DEBIAN_FRONTEND="noninteractive" \
PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
PLEX_ARCH="amd64" \
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
PLEX_MEDIA_SERVER_USER="abc" \
PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (dockserver.io)"

RUN \
 echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y \
	beignet-opencl-icd \
	jq \
	ocl-icd-libopencl1 \
	udev \
	unrar \
	wget \
	i965-va-driver && \
 COMP_RT_RELEASE=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/latest" | jq -r '.tag_name') && \
 COMP_RT_URLS=$(curl -sX GET "https://api.github.com/repos/intel/compute-runtime/releases/tags/${COMP_RT_RELEASE}" | jq -r '.body' | grep wget | sed 's|wget ||g') && \
 mkdir -p /opencl-intel && \
 for i in ${COMP_RT_URLS}; do \
	i=$(echo ${i} | tr -d '\r'); \
	echo "**** downloading ${i} ****"; \
	curl -o "/opencl-intel/$(basename ${i})" \
		-L "${i}"; \
 done && \
 dpkg -i /opencl-intel/*.deb && \
 rm -rf /opencl-intel && \
 echo "**** install plex ****" && \
  curl -o \
	/tmp/plexmediaserver.deb -L \
	"${PLEX_DOWNLOAD}/${VERSION}/debian/plexmediaserver_${VERSION}_${PLEX_ARCH}.deb" && \
 dpkg -i /tmp/plexmediaserver.deb && \
 echo "**** ensure abc user's home folder is /app ****" && \
 usermod -d /app abc && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/etc/default/plexmediaserver \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY ./apps/docker-plex/root/ /

# ports and volumes
EXPOSE 32400/tcp
VOLUME /config
