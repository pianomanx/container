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
   apk --quiet --no-cache --no-progress upgrade && \
   apk --quiet --no-cache --no-progress add shadow 

   addgroup -S abc
   adduser -S abc -G abc

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
   apk add --quiet --no-cache --no-progress --virtual=build-dependencies \
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
   GIT="https://github.com/dockserver/dockserver.git"
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
      if [[ ! -z "${VERSION}" || "${VERSION}" != "null" || "${VERSION}" != "" ]]; then
         echo "${VERSION}" | tee "/tmp/VERSION" > /dev/null
         if [[ ${VERSION#*v} == ${LOCAL#*v} ]]; then
            log "**** Local ${NONREMOTE} is the same as Remote ${VERSION} of Dockserver || no update needed ****"
         else
           log "**** downloading dockserver ${VERSION} ****" && \
           aria2c -x2 -k1M -d /tmp -o dockserver.tar.gz ${GTHUB}/v${VERSION}.tar.gz
           if [[ ! -f "${FILETMP}" ]]; then
              log "**** check of ${FILETMP} is failed || fallback to git-clone ****"
              apk --quiet --no-cache --no-progress add git && \
              git clone --quiet ${GIT} ${FOLDER}
              REMOGIT=$(git describe --tags `git rev-list --tags --max-count=1`)
              echo "${REMOGIT#*v}" | tee "/tmp/VERSION" > /dev/null
           else 
              log "**** check of ${FILETMP} positiv ****"
              if [[ ! -f "${FOLDER}/install.sh" ]]; then
                 log "**** check of ${FOLDER} is negativ | create the folder now****"
                 mkdir -p ${FOLDER} && \
                 unpigz -dcqp 16 "${FILETMP}" | pv -pterb | tar pxf - -C "${FOLDER}" --strip-components=1 && \
                 rm -rf ${FILETMP} && echo "${VERSION#*v}" | tee "/tmp/VERSION" > /dev/null
              else
                 log "**** check of ${FOLDER} is positiv ****"
                 if [[ ! -d "${FOLDER}/apps/myapps" ]] ; then
                    log "**** check if ${FILETMP} available ****" && \
                    unpigz -dcqp 16 "${FILETMP}" | pv -pterb | tar pxf - -C "${FOLDER}" --strip-components=1 && \
                    rm -rf ${FILETMP} && echo "${VERSION#*v}" | tee "/tmp/VERSION" > /dev/null
                    log "**** Update dockserver to $ ${VERSION#*v} completed ****"
                 else
                    log "**** check if ${FOLDER}/apps/myapps is available ****"
                    mkdir -p "${FOLDERTMP}" && mv "${FOLDER}/apps/myapps" "${FOLDERTMP}/myapps" && \
                    unpigz -dcqp 16 ${FILETMP} | pv -pterb | tar pxf - -C "${FOLDER}" --strip-components=1 && \
                    cp -r "${FOLDERTMP}/myapps" "${FOLDER}/apps/myapps" && \
                    rm -rf "${FILETMP}" && echo "${LOCAL#*v}" | tee "/tmp/VERSION" > /dev/null
                    log "**** Update dockserver to ${VERSION#*v} completed ****"
                 fi
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
