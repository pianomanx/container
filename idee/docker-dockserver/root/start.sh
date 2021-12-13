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

function log() {

   echo "[INSTALL] DockServer ${1}"

}

function first() {

   log "**** update system packages ****" && \
   apk --quiet --no-cache --no-progress update && \
   apk --quiet --no-cache --no-progress upgrade

   PGID=${PGID:-1000}
   PUID=${PUID:-1000}

   if [ ! "$(id -u abc)" -eq "$PUID" ]; then
      usermod -o -u "$PUID" abc
   fi
   if [ ! "$(id -g abc)" -eq "$PGID" ]; then
      groupmod -o -g "$PGID" abc
   fi
}

function build() {
   log "**** install build packages ****" && \
   apk add --no-cache --virtual=build-dependencies \
	aria2 \
	curl \
	bc \
	findutils \
	coreutils \
	tar \
	git \
	jq \
	pv \
	pigz \
	tzdata
}

function run() {
LASTRUN=`date +%s`

while :
 do

   YET=`date +%s`  
   FOLDER=/opt/dockserver
   FOLDERTMP=/tmp/dockserver
   FILETMP=/tmp/dockserver.tar.gz
   URL="https://api.github.com/repos/dockserver/dockserver/releases/latest"
   GTHUB="https://github.com/dockserver/dockserver"

   DIFF=$(($YET-$LASTRUN))

   if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ];then

      if test -f "/tmp/VERSION";then
         LOCAL="$(cat /tmp/VERSION)"
      else
         LOCAL=null
      fi

      VERSION="$(curl -sX GET "${URL}" | jq -r '.tag_name')"
      NONREMOTE="${LOCAL#*v}"
      VERSION="${VERSION#*v}"

      if [[ ! -z "${VERSION}" || "${VERSION}" != "null" ]]; then
         echo "${VERSION}" | tee "/tmp/VERSION" > /dev/null
         if [[ ${VERSION#*v} == ${LOCAL#*v} ]]; then
            log "**** LOCAL ${NONREMOTE} is the same as Remote ${VERSION} of Dockserver || no update needed ****" && \
            break
         else
           log "**** install dockserver ${VERSION} ****" && \
           aria2c -x2 -k1M -d /tmp -o dockserver.tar.gz ${GTHUB}/archive/refs/tags/v${VERSION}.tar.gz
           if test -f "${FILETMP}";then
              if test -d "/tmp/dockserver"; then
                 if test -d "${FOLDER}/apps/myapps"; then
                    unpigz -dcqp 8 ${FILETMP} | pv -pterb | tar pxf - -C ${FOLDERTMP} --strip-components=1
                    cp -rv ${FOLDER}/apps/myapps ${FOLDERTMP}/apps/myapps
                    rm -rf ${FOLDER} && mv ${FOLDERTMP} ${FOLDER}
                    echo "${LOCAL#*v}" | tee "/tmp/VERSION" > /dev/null
                 fi
              else
                 unpigz -dcqp 8 ${FILETMP} | pv -pterb | tar pxf - -C ${FOLDER} --strip-components=1
                 echo "${VERSION#*v}" | tee "/tmp/VERSION" > /dev/null
              fi
           fi
         fi
      fi
   fi
   sleep 720
done
}
   ## RUN IN ORDER
   first
   build 
   run
   ##
