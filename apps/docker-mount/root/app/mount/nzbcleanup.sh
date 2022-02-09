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
# shellcheck disable=SC2086
# shellcheck disable=SC2002
# shellcheck disable=SC2006
## GLOBAL SETTINGS

if pidof -o %PPID -x "$0"; then
   exit 1
fi

SMOUNT=/app/cleanup
if [[ -f "${SMOUNT}/nzbcleanup.sh" ]]; then chmod 777 ${SMOUNT}/nzbcleanup.sh; fi

while true; do

   source /system/mount/mount.env
   pathglobal=/mnt
   DRIVEPERCENT=$(df --output=pcent ${pathglobal} | tr -dc '0-9')
   DRIVEUSEDPERCENT=${DRIVEUSEDPERCENT} 
   NZBCLEANUP=${NZBCLEANUP}
   NZBBACKUPFOLDER=${NZBBACKUPFOLDER}
   NZBBACKUPTIME=${NZBBACKUPTIME}
   NZBDOWNLOADFOLDER=${NZBDOWNLOADFOLDER}
   NZBDOWNLOADFOLDERTIME=${NZBDOWNLOADFOLDERTIME}

   if [[ ${NZBCLEANUP} != "false" ]]; then
      if [[ ! ${DRIVEPERCENT} -ge ${DRIVEUSEDPERCENT} ]]; then
         sleep 120
      else
         $(command -v find) ${NZBBACKUPFOLDER}/* -type d -mmin +${NZBBACKUPTIME} -exec rm -rf {} \; >/dev/null 2>&1
         $(command -v find) ${NZBDOWNLOADFOLDER}/* -type f -mmin +${NZBDOWNLOADTIME} -exec rm -rf {} \; >/dev/null 2>&1
         sleep 120
      fi
   else
      sleep 120
   fi
done
#<EOF>#
