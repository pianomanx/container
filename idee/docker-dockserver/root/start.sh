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
   groupmod -o -g "$PGID" abc
   usermod -o -u "$PUID" abc

}

function unwanted() {

echo -e ".git
.github
CONTRIBUTING.md
README.md
SECURITY.md
backup.sh
config.json
get_pull_request_title.rb
renovate.json
wgetfile.sh
.all-contributorsrc
.mergify.yml
changelog-ci-config.yaml
.editorconfig
.gitignore
.gitattributes
wiki" > /tmp/unwanted

## cleanup unused files and folders

   sed '/^\s*#.*$/d' /tmp/unwanted | \
   while IFS=$'\n' read -r -a myArray; do
       rm -rf ${FOLDER}/${myArray[0]} > /dev/null
   done
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
   GTHUB="https://github.com/dockserver/dockserver/archive/refs/tags"

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
            log "**** LOCAL ${NONREMOTE} is the same as Remote ${VERSION} of Dockserver || no update needed ****"
         else
           log "**** install dockserver ${VERSION} ****" && \
           aria2c -x2 -k1M -d /tmp -o dockserver.tar.gz ${GTHUB}/v${VERSION}.tar.gz
           if test -f "${FILETMP}";then
              if test -d "${FOLDER}"; then
                 if test -d "${FOLDER}/apps/myapps"; then
                    mkdir -p ${FOLDERTMP} && cp -r ${FOLDER}/apps/myapps ${FOLDERTMP}/myapps && \
                    unpigz -dcqp 16 ${FILETMP} | pv -pterb | tar pxf - -C ${FOLDER} --strip-components=1 && \
                    cp -r ${FOLDERTMP}/myapps ${FOLDER}/apps/myapps && \
                    rm -rf ${FILETMP} && echo "${LOCAL#*v}" | tee "/tmp/VERSION" > /dev/null
                 fi
              else
                 unpigz -dcqp 16 ${FILETMP} | pv -pterb | tar pxf - -C ${FOLDER} --strip-components=1 && \
                 rm -rf ${FILETMP} && echo "${VERSION#*v}" | tee "/tmp/VERSION" > /dev/null
              fi
              GUID=$(stat -c '%g' "${FOLDER}"/* | head -n 1)
              if [[ $GUID == 0 ]]; then chown -cR abc:abc ${FOLDER} > /dev/null; fi
              unwanted
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
