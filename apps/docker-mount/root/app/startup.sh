#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.  #
# started from Zero  #
# Docker owned dockserver  #
# Docker Maintainer dockserver#
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE#
# NO CUSTOMIZING IS ALLOWED#
# NO REBRANDING IS ALLOWED #
# NO CODE MIRRORING IS ALLOWED#
#####################################
# shellcheck disable=SC2086
# shellcheck disable=SC2006

function log() {
   echo "[Mount] ${1}"
}
if pidof -o %PPID -x "$0"; then
   exit 1
fi

## Bad rclone
cp -r /app/rclone/rclone.conf /root/.config/rclone/
## Bad rclone

source /system/mount/mount.env
source /app/mount/function.sh

lang && sleep 5 || exit 1
LANGUAGE=${LANGUAGE}
startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
log "${startupmount}"

mkdir -p "${TMPRCLONE}" "${REMOTE}" && sleep 5 || exit 1

rcstart && sleep 5 || exit 1
rcset && sleep 5 || exit 1
rcmount && sleep 5 || exit 1

sleep 120

while true; do
   if [ "$(ls -A ${REMOTE})" ]; then
      log "${startuprcloneworks}"
   else
      startup
   fi
   envrenew && lang && sleep 360 && checkban
done

#<EOF>#
