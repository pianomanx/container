FROM lsiobase/alpine:3.12

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MULTITAUTULLI_RELEASE

# Inform app this is a docker env
ENV MULTITAUTULLI_DOCKER=True

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	py3-pip && \
 echo "**** install packages ****" && \
 apk add --no-cache \
	python3 \
	python3-venv \
	python3-all-dev
RUN \
 echo "**** install app ****" && \
    cd /opt && \
       git clone https://github.com/zSeriesGuy/Tautulli.git && \
       addgroup tautulli && adduser --system --no-create-home tautulli --ingroup tautulli && \
       chown tautulli:tautulli -R /opt/Tautulli && \
    cd /opt/Tautulli && \
       python3 -m venv /opt/Tautulli && \
       source /opt/Tautulli/bin/activate && \
       pip3 install -r /opt/Tautulli/requirements.txt

RUN \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*
RUN \
 echo "**** Starting Multi Tautulli ****" && \
   cp /opt/Tautulli/init-scripts/init.systemd /lib/systemd/system/tautulli.service && \
      systemctl daemon-reload && sudo systemctl enable tautulli.service && \
      systemctl start tautulli.service

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
