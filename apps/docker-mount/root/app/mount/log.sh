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
path=/system/mount/logs

if pidof -o %PPID -x "$0"; then
   exit 1
fi

while true; do
  LSTATS=$(stat -c %s ${path}/rclone-union.log)
  if [[ ${LSTATS} -ge "2000000" ]]; then
     $(command -v truncate) -s 0 ${path}/*.log
  fi
  sleep 6h
done
#<EOF>#
