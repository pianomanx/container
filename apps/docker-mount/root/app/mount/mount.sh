#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE      #
# NO CUSTOMIZING IS ALLOWED         #
# NO REBRANDING IS ALLOWED          #
# NO CODE MIRRORING IS ALLOWED      #
#####################################

if pidof -o %PPID -x "$0"; then
   exit 1
fi

## Bad rclone
cp -r /app/rclone/rclone.conf /root/.config/rclone/
## Bad rclone

source /system/mount/mount.env
source /app/mount/function.sh

mkdir -p "${TMPRCLONE}" "${REMOTE}" && echo OK || exit 1

lang && sleep 5 || exit 1
rcstart && sleep 5 || exit 1
rcset && sleep 5 || exit 1
rcmount && sleep 5 || exit 1

sleep 30

while true; do
   if [[ "$(ls -A /mnt/unionfs)" ]]; then
      sleep 360
   else
      rckill && sleep 5 && rcstart && refreshVFS && sleep 360
   fi
done

#EOF
