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
ENV="/system/mount/mount.env"
VFS_REFRESH=$(grep -e "VFS_REFRESH" "$ENV" | sed "s#.*=##")

function drivecheck() {
   while true; do
      MERGERFS_PID=$(pgrep mergerfs)
      if [ ! "${MERGERFS_PID}" ]; then
         sleep 5 && continue
      else
         break
      fi
   done
   ###
   while true; do
      SMOUNT=/app/vfs/refresh.sh
      if [[ -f ${SMOUNT} ]]; then
         log=$(grep -e "log" "${SMOUNT}" | sed "s#.*=##")
         bash ${SMOUNT}
         chmod a+x ${SMOUNT}
         chown -hR abc:abc ${SMOUNT}
         truncate -s 0 ${log}
         break
      fi
   done
}
while true; do
   if [[ ! "${VFS_REFRESH}" ]]; then
      break
   else
      drivecheck && sleep "${VFS_REFRESH}" && continue
   fi
done
#<EOF>#
