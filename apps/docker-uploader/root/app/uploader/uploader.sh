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
# shellcheck disable=SC2003
# shellcheck disable=SC2006
# shellcheck disable=SC2207
# shellcheck disable=SC2012
# shellcheck disable=SC2086
# shellcheck disable=SC2196

function log() {
    echo "${1}"
}
if pidof -o %PPID -x "$0"; then
    exit 1
fi

log "dockserver.io Multi-Thread Uploader started"
BASE=/system/uploader
find ${BASE} -type f -name '*.log' -delete
CONFIG=/system/servicekeys/rclonegdsa.conf
mkdir -p /system/uploader/{logs,done}
mkdir -p /system/uploader/json/{done,upload}

if `rclone config show --config=${CONFIG} | grep ":/encrypt" &>/dev/null`;then
  export CRYPTED=C
else
  export CRYPTED=""
fi
if ! `rclone config show --config=${CONFIG} | grep "local" &>/dev/null`;then
   rclone config create down local nunc 'true' --config=${CONFIG}
fi
if `rclone config show --config=${CONFIG} | grep "GDSA" &>/dev/null`;then
  export KEY=GDSA
elif `rclone config show --config=${CONFIG} | head -n1 | grep -Po '\[.*?]' | sed 's/.*\[\([^]]*\)].*/\1/' | sed '/GDSA/d'`;then
  export KEY=""
else
  log "no match found of GDSA[01=~100] or [01=~100]"
  sleep infinity
fi

KEYLOCAL=/system/servicekeys/keys/
ARRAY=($(ls -1v ${KEYLOCAL} | egrep '(PG|GD|GS|0)'))
COUNT=$(expr ${#ARRAY[@]} - 1)
if [[ -f "/system/uploader/.keys/lasteservicekey" ]]; then
  USED=$(cat /system/uploader/.keys/lasteservicekey)
  echo "${USED}" | tee /system/uploader/.keys/lasteservicekey > /dev/null
else
  USED=1 && echo "${USED}" | tee /system/uploader/.keys/lasteservicekey > /dev/null
fi

EXCLUDE=/system/uploader/rclone.exclude
if [[ ! -f ${EXCLUDE} ]]; then
   cat > ${EXCLUDE} << EOF; $(echo)
*-vpn/**
torrent/**
nzb/**
nzbget/**
.inProgress/**
jdownloader2/**
tubesync/**
aria/**
temp/**
qbittorrent/**
.anchors/**
sabnzbd/**
deluge/**
EOF
fi

LOGFILE=/system/uploader/logs
START=/system/uploader/json/upload
DONE=/system/uploader/json/done
CHK=/system/uploader/logs/check.log
DOWN=/mnt/downloads

while true;do 
   if [ "${USED}" -eq "${COUNT}" ]; then USED=1 ;else USED=${USED}; fi
   source /system/uploader/uploader.env
   BWLIMIT=""
   SRC="down:${DOWN}"
   if [[ "${BANDWITHLIMIT}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
      BWLIMIT="--bwlimit=${BANDWITHLIMIT}"
   fi
   if [[ "${DRIVEUSEDSPACE}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
      source /system/uploader/uploader.env
      while true;do 
         LCT=$(df --output=pcent ${DOWN} | tail -n 1 | cut -d'%' -f1)
         if [ $DRIVEUSEDSPACE \> $LCT ]; then sleep 5 && continue;else sleep 5 && break;fi
      done
   fi
   log "CHECKING LOCAL SOURCE FOLDERS"
   rclone ls ${SRC} --min-age=${MIN_AGE_FILE} --fast-list --config=${CONFIG} --exclude-from=${EXCLUDE} | awk '{print $2}' > "${CHK}" 2>&1
   if [ `cat ${CHK} | wc -l` -gt 0 ]; then
      log "STARTING RCLONE MOVE from ${SRC} to REMOTE"
      sed '/^\s*#.*$/d' | while IFS=$'\n' read -r -a UPP; do
         MOVE=${MOVE:-/}
         FILE=$(basename "${UPP[@]}")
         DIR=$(dirname "${UPP[@]}" | sed "s#${DOWN}/${MOVE}##g")
         SIZE=$(stat -c %s "${DOWN}/${UPP[@]}" | numfmt --to=iec-i --suffix=B --padding=7)
         STARTZ=$(date +%s)
         USED=${USED}
         touch "${LOGFILE}/${FILE}.txt"
         echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"logfile\": \"${LOGFILE}/${FILE}.txt\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\"}" >"${START}/${FILE}.json"
         rclone move "${DOWN}/${UPP[@]}" "${KEY}$[USED]${CRYPTED}:/${UPP[@]}" --config=${CONFIG} --stats=1s --checkers=16 --use-mmap --no-traverse --check-first \
                --log-level=${LOG_LEVEL} --user-agent=${USERAGENT} ${BWLIMIT} --delete-empty-src-dirs --log-file="${LOGFILE}/${FILE}.txt" --tpslimit 50 --tpslimit-burst 50
         ENDZ=$(date +%s)
         echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\",\"starttime\": \"${STARTZ}\",\"endtime\": \"${ENDZ}\"}" >"${DONE}/${FILE}.json"
         sleep 5
         tail -n 20 "${LOGFILE}/${FILE}.txt" | grep --line-buffered 'googleapi: Error' | while read; do
             USED=$(( "${USED}" + 1 ))
             echo "${USED}" | tee "/system/uploader/.keys/lasteservicekey" > /dev/null
         done
         rm -f "${START}/${FILE}.json" "${LOGFILE}/${FILE}.txt"
         chmod 755 "${DONE}/${FILE}.json"
      done
      log "MOVE FINISHED moving $num_files files from ${SRC} to REMOTE"
   else
      log "MOVE skipped || less then 1 file" && sleep 60
   fi
done

##E-o-F##
