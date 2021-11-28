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

SMOUNT=/app/vfs
folder=/system/uploader/vfsforget

if [[ -d "${folder}" ]]; then
   chown -hR 1000:1000 "${folder}"
else
   mkdir -p "${folder}" && chown -hR 1000:1000 "${folder}"
fi

if [[ -f "${SMOUNT}/forget.sh" ]]; then chmod 777 ${SMOUNT}/forget.sh; fi

while true; do
   IFS=$'\n'
   filter="$1"
   mapfile -t files < <(eval find ${folder} -type f -name '*.json' | grep "$filter")
   if [[ ${#files[@]} -gt 0 ]]; then
      for i in "${files[@]}"; do
         command=$(grep -Po '"vfsforget": *\K"[^"]*"' "${i}" | sed 's/"\|,//g')
         for FF in ${command}; do
            ${SMOUNT}/forget.sh "${FF}" &
            rm -f "${i}" && sleep 5
         done
      done
   else
      sleep 30
   fi
done
#<EOF>#
