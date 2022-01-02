#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.              #
# started from Zero                 #
# Docker owned dockserver           #
# Docker Maintainer dockserver      #
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
if pidof -o %PPID -x "$0"; then exit 1; fi

log "dockserver.io Multi-Thread Uploader started"
BASE=/system/uploader
CONFIG=/system/servicekeys/rclonegdsa.conf
KEYLOCAL=/system/servicekeys/keys/
LOGFILE=/system/uploader/logs
START=/system/uploader/json/upload
DONE=/system/uploader/json/done
CHK=/system/uploader/logs/check.log
EXCLUDE=/system/uploader/rclone.exclude
MAXT=730
CRYPTED=""
DIFF=0
MINSA=1
BWLIMIT=""
USERAGENT=""

find ${BASE} -type f -name '*.log' -delete
mkdir -p "${LOGFILE}" "${START}" "${DONE}"
if `rclone config show --config=${CONFIG} | grep ":/encrypt" &>/dev/null`;then
   export CRYPTED=C
fi
if `rclone config show --config=${CONFIG} | grep "GDSA" &>/dev/null`;then
   export KEY=GDSA
elif `rclone config show --config=${CONFIG} | head -n1 | grep -Po '\[.*?]' | sed 's/.*\[\([^]]*\)].*/\1/' | sed '/GDSA/d'`;then
   export KEY=""
else
   log "no match found of GDSA[01=~100] or [01=~100]"
   sleep infinity
fi
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

ARRAY=$(ls -1v ${KEYLOCAL} | wc -l )
MAXSA=$(expr ${#ARRAY[@]})
if [[ -f "/system/uploader/.keys/lasteservicekey" ]]; then
   USED=$(cat /system/uploader/.keys/lasteservicekey)
   echo "${USED}" | tee /system/uploader/.keys/lasteservicekey > /dev/null
else
   USED=$MINSA && echo "${MINSA}" | tee /system/uploader/.keys/lasteservicekey > /dev/null
fi

while true;do 
   source /system/uploader/uploader.env
   DLFOLDER=${DLFOLDER}
   if [[ "${BANDWITHLIMIT}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then BWLIMIT="--bwlimit=${BANDWITHLIMIT}" ;fi
   if [[ "${DRIVEUSEDSPACE}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
      source /system/uploader/uploader.env
      while true;do 
         LCT=$(df --output=pcent ${DLFOLDER} | tail -n 1 | cut -d'%' -f1)
         if [ $DRIVEUSEDSPACE \> $LCT ]; then sleep 60 && continue;else sleep 5 && break;fi
      done
   fi
   log "CHECKING LOCAL SOURCE FOLDERS"
   rclone lsf --files-only --recursive --min-age=${MIN_AGE_FILE} --format="p" --order-by="modtime" --config=${CONFIG} --exclude-from=${EXCLUDE} "${DLFOLDER}" > "${CHK}" 2>&1
   if [ `cat ${CHK} | wc -l` -gt 0 ]; then
      log "STARTING RCLONE MOVE from ${SRC} to REMOTE"
      cat "${CHK}" | while IFS=$'\n' read -r -a UPP; do
         MOVE=${MOVE:-/}
         FILE=$(basename "${UPP[@]}")
         DIR=$(dirname "${UPP[@]}" | sed "s#${DLFOLDER}/${MOVE}##g")
         SIZE=$(stat -c %s "${DLFOLDER}/${UPP[@]}" | numfmt --to=iec-i --suffix=B --padding=7)
         STARTZ=$(date +%s)
         USED=${USED}
         USERAGENT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
         touch "${LOGFILE}/${FILE}.txt"
            echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"logfile\": \"${LOGFILE}/${FILE}.txt\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\"}" >"${START}/${FILE}.json"
         rclone move "${DLFOLDER}/${UPP[@]}" "${KEY}$[USED]${CRYPTED}:/${UPP[@]}" --config=${CONFIG} --stats=1s --checkers=32 --use-mmap --no-traverse --check-first --delete-empty-src-dirs \
           --drive-chunk-size=64M --log-level=${LOG_LEVEL} --user-agent=${USERAGENT} ${BWLIMIT} --log-file="${LOGFILE}/${FILE}.txt" --tpslimit 50 --tpslimit-burst 50
         ENDZ=$(date +%s)
            echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\",\"starttime\": \"${STARTZ}\",\"endtime\": \"${ENDZ}\"}" >"${DONE}/${FILE}.json"
         sleep 5
         UPFILE=`eval rclone size "${KEY}$[USED]${CRYPTED}:/${UPP[@]}" --json | cut -d ":" -f3 | cut -d "}" -f1`
         FILEGB=$(( $UPFILE/1024**3 ))
         DIFF=$(( $DIFF+$FILEGB ))
            if [[ $DIFF -gt $MAXT ]]; then 
               USED=$(( $USED+$MINSA ))
               if [[ "${USED}" -eq "${MAXSA}" ]]; then USED=$MINSA && echo "${USED}" | tee "/system/uploader/.keys/lasteservicekey" > /dev/null ;fi
            elif [[ $MAXT -gt $DIFF ]]; then
               tail -n 20 "${LOGFILE}/${FILE}.txt" | grep --line-buffered 'googleapi: Error' | while read -r; do
                   USED=$(( $USED+$MINSA )) && 
                   if [[ "${USED}" -eq "${MAXSA}" ]];then USED=$MINSA && echo "${USED}" | tee "/system/uploader/.keys/lasteservicekey" > /dev/null ;fi
               done
            else
               DIFF=$DIFF
            fi
         rm -f "${START}/${FILE}.json" "${LOGFILE}/${FILE}.txt" && chmod 755 "${DONE}/${FILE}.json"
         if [ $DRIVEUSEDSPACE \> $LCT ]; then rm -rf "${CHK}" && sleep 5 && break;fi
      done
      log "MOVE FINISHED from ${SRC} to REMOTE"
   else
      log "MOVE skipped || less then 1 file" && sleep 180
   fi
done

##E-o-F##
