FROM ghcr.io/linuxserver/baseimage-alpine:3.15-a0482dc2-ls1

# set version label
ARG VERSION
ARG MULTITAUTULLI_RELEASE

# Inform app this is a docker env
ENV MULTITAUTULLI_DOCKER=True

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache git && \
 apk add --no-cache --virtual=build-dependencies \
	py3-pip && \
 echo "**** install packages ****" && \
 apk add --no-cache \
	python3 \
	python3-venv \
	python3-all-dev
RUN \
  echo "**** clone multi tautulli app ****" && \
  git clone --quiet https://github.com/zSeriesGuy/Tautulli.git /opt/tautulli && \
     addgroup tautulli && adduser --system --no-create-home tautulli --ingroup tautulli && \
     chown tautulli:tautulli -R /opt/tautulli

RUN \
  echo "**** install multi tautulli app ****" && \
  cd /opt/tautulli && \
     python3 -m venv /opt/tautulli \
     source /opt/tautulli/bin/activate \
     pip3 install -r /opt/tautulli/requirements.txt

RUN \
  echo "**** cleanup ****" && \
    apk del --purge \
        build-dependencies && \
  rm -rf \
      /root/.cache \
      /tmp/*

COPY ./apps/docker-multitautulli/root/ /

RUN \
  echo "**** Starting Multi Tautulli ****" && \
      ln -s /opt/init.systemd /lib/systemd/system/tautulli.service && \
      systemctl daemon-reload && sudo systemctl enable tautulli.service && \
      systemctl start tautulli.service

# ports and volumes
VOLUME /config /logs
EXPOSE 8181
