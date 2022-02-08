FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV TAUTULLI_DOCKER=True

RUN \
   echo "**** install build packages ****" && \
     apk add --no-cache --virtual=build-dependencies g++ gcc make py3-pip python3-dev && \
   echo "**** install packages ****" && \
     apk add --no-cache tar curl git jq py3-openssl py3-setuptools python3 && \
   echo "**** install pip packages ****" && \
     pip3 install --no-cache-dir -U mock plexapi pycryptodomex && \
   echo "**** install app ****" && \
     mkdir -p /app/tautulli && \
   TAUTULLI_RELEASE=$(curl -sX GET "https://api.github.com/repos/Tautulli/Tautulli/releases/latest" | jq -r '. | .tag_name') && \
     curl -fsSL "https://github.com/Tautulli/Tautulli/archive/${TAUTULLI_RELEASE}.tar.gz" | tar xzf - -C /app/tautulli --strip-components=1 && \
   echo "**** update requirements of python3 ****" && \
     python3 -m pip install --upgrade pip && \
     python3 -m pip install --upgrade --force-reinstall -r /app/tautulli/requirements.txt && \
   echo "**** Hard Coding versioning ****" && \ 
   echo "${TAUTULLI_RELEASE}" > /app/tautulli/version.txt && \
   echo "master" > /app/tautulli/branch.txt && \
   echo "**** cleanup ****" && \
     apk del --purge build-dependencies && \
     rm -rf /root/.cache /tmp/*

# add local files
COPY ./apps/docker-tautulli/root/ /

# ports and volumes
VOLUME /config

EXPOSE 8181

HEALTHCHECK --start-period=90s CMD curl -ILfSs http://localhost:8181/status > /dev/null || curl -ILfkSs https://localhost:8181/status > /dev/null || exit 1

