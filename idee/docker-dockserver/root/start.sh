#!/usr/bin/bash
# shellcheck shell=bash
#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
# shellcheck disable=SC2003
# shellcheck disable=SC2006
# shellcheck disable=SC2207
# shellcheck disable=SC2012
# shellcheck disable=SC2086
# shellcheck disable=SC2196
# shellcheck disable=SC2046

FOLDER=/opt/dockserver
FOLDERTMP=/tmp/dockserver

function log() {
   echo "[INSTALL] DockServer ${1}"
}

apk --quiet --no-cache --no-progress update && \
apk --quiet --no-cache --no-progress upgrade && \
apk del --quiet --clean-protected --no-progress && \
rm -rf /var/cache/apk/* /tmp/*

if [ -z `command -v git` ]; then apk --quiet --no-cache --no-progress add git; fi
if [ -z `command -v curl` ]; then apk --quiet --no-cache --no-progress add curl; fi

FOLDER=${FOLDER}

VERSION=$(curl -sX GET "https://api.github.com/repos/dockserver/dockserver/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_^v__')

https://github.com/dockserver/dockserver/archive/refs/tags/v${VERSION}.tar.gz
