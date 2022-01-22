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
function log() {
    echo "${1}"
}

log "dockserver.io Multi-Thread Uploader started"

BASE=/system/uploader
CONFIG=/system/servicekeys/rclonegdsa.conf
KEYLOCAL=/system/servicekeys/keys/
LOGFILE=/system/uploader/logs
START=/system/uploader/json/upload
DONE=/system/uploader/json/done
CHK=/system/uploader/logs/check.log
EXCLUDE=/system/uploader/rclone.exclude
LTKEY=/system/uploader/.keys/last
MAXT=730
MINSA=1
DIFF=1
CRYPTED=""
BWLIMIT=""
USERAGENT=""

mkdir -p "${LOGFILE}" "${START}" "${DONE}" 
find "${BASE}" -type f -name '*.log' -delete
find "${BASE}" -type f -name '*.txt' -delete
find "${START}" -type f -name '*.json' -delete

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

ARRAY=$(ls -A ${KEYLOCAL} | wc -l )
MAXSA=${ARRAY}
RANKEY=$(( $RANDOM % ${ARRAY} ))

if [[ ! -f "${LTKEY}" ]]; then
   touch "${LTKEY}" && echo "$RANKEY" > "${LTKEY}"
else
   cat ${LTKEY} | while IFS=$'\n' read -ra KEY; do
      if [[ "${KEY[@]}" -eq "${MINSA}" ]]; then
         echo "$RANKEY" > "${LTKEY}"
      elif [[ "${KEY[@]}" -eq "${MAXSA}" ]]; then
           echo "${MINSA}" > "${LTKEY}"
      else
         echo "${KEY[@]}" > "${LTKEY}"
      fi
   done
fi

while true;do 
   source /system/uploader/uploader.env
   DLFOLDER=${DLFOLDER}
   if [[ "${BANDWITHLIMIT}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then BWLIMIT="--bwlimit=${BANDWITHLIMIT}" ; fi
   if [[ "${DRIVEUSEDSPACE}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
      source /system/uploader/uploader.env
      while true; do 
        LCT=$(df --output=pcent ${DLFOLDER} --exclude={${DLFOLDER}/nzb,${DLFOLDER}/torrent} | tail -n 1 | cut -d'%' -f1)
        if [[ "${DRIVEUSEDSPACE}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
          if [[ "${LCT}" -gt "${DRIVEUSEDSPACE}" ]]; then sleep 5 && break ; else sleep 30 && continue ; fi
        fi
      done
   fi
   COUNTFILES=$(rclone lsf --files-only -R --min-age="${MIN_AGE_FILE}" --exclude-from="${EXCLUDE}" "${DLFOLDER}" | wc -l)
   rclone lsf --files-only -R --min-age="${MIN_AGE_FILE}" --separator "|" --format="tp" --order-by="modtime" --exclude-from="${EXCLUDE}" "${DLFOLDER}" | sort  > "${CHK}" 2>&1
   if [ "${COUNTFILES}" -gt 0 ]; then
      cat "${CHK}" | while IFS=$'\n|' read -ra UPP; do
         if [[ -f "${LTKEY}" ]]; then USED=$(cat ${LTKEY}) ; else USED=${USED} ; fi
         MOVE=${MOVE:-/}
         FILE=$(basename "${UPP[1]}")
         DIR=$(dirname "${UPP[1]}" | sed "s#${DLFOLDER}/${MOVE}##g")
         STARTZ=$(date +%s)
         SIZE=$(stat -c %s "${DLFOLDER}/${UPP[1]}" | numfmt --to=iec-i --suffix=B --padding=7)
         while true ; do
            SUMSTART=$(stat -c %s "${DLFOLDER}/${UPP[1]}")
            sleep 5
            SUMTEST=$(stat -c %s "${DLFOLDER}/${UPP[1]}")
            if [[ "$SUMSTART" -eq "$SUMTEST" ]]; then sleep 1 && break ; else sleep 1 && continue ; fi
         done
         UPFILE=$(rclone size "${DLFOLDER}/${UPP[1]}" --config="${CONFIG}" --json | cut -d ":" -f3 | cut -d "}" -f1)
         touch "${LOGFILE}/${FILE}.txt"
            echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"logfile\": \"${LOGFILE}/${FILE}.txt\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\"}" > "${START}/${FILE}.json"
         rclone move "${DLFOLDER}/${UPP[1]}" "${KEY}$[USED]${CRYPTED}:/${DIR}/" --config="${CONFIG}" \
            --stats=1s --checkers=32 --use-mmap --no-traverse --check-first --drive-chunk-size=64M \
            --log-level="${LOG_LEVEL}" --user-agent="${USERAGENT}" ${BWLIMIT} --log-file="${LOGFILE}/${FILE}.txt" \
            --tpslimit 50 --tpslimit-burst 50 --min-age="${MIN_AGE_FILE}"
         ENDZ=$(date +%s)
            echo "{\"filedir\": \"${DIR}\",\"filebase\": \"${FILE}\",\"filesize\": \"${SIZE}\",\"gdsa\": \"${KEY}$[USED]${CRYPTED}\",\"starttime\": \"${STARTZ}\",\"endtime\": \"${ENDZ}\"}" > "${DONE}/${FILE}.json"
         FILEGB=$(( $UPFILE/1024**3 ))
         DIFF=$(( $DIFF+$FILEGB ))
         source /system/uploader/uploader.env
            LCT=$(df --output=pcent ${DLFOLDER} --exclude={${DLFOLDER}/nzb,${DLFOLDER}/torrent} | tail -n 1 | cut -d'%' -f1)
            if [[ "${DRIVEUSEDSPACE}" =~ ^[0-9][0-9]+([.][0-9]+)?$ ]]; then
               if [[ ! "${LCT}" -gt "${DRIVEUSEDSPACE}" ]]; then
                  rm -rf "${CHK}" "${LOGFILE}/${FILE}.txt" "${START}/${FILE}.json"
                  DIFF=1 && chmod 755 "${DONE}/${FILE}.json" 
                  break
               fi
            elif [[ "${USED}" -eq "${MAXSA}" ]]; then
                 USED=$MINSA && DIFF=1 && echo "${USED}" > "${LTKEY}"
            elif [[ ! $DIFF -gt $MAXT ]]; then
                 USED=$(( $USED+$MINSA ))
                 if [[ "${USED}" -eq "${MAXSA}" ]]; then
                    USED=$MINSA && DIFF=1 && echo "${USED}" > "${LTKEY}"
                 else
                    echo "${USED}" > "${LTKEY}"
                 fi
            elif [[ ! "$MAXT" -gt "$DIFF" ]]; then
                if test -f "${LOGFILE}/${FILE}.txt" ; then
                   tail -Fn 20 "${LOGFILE}/${FILE}.txt" | while read line; do
                      echo "$line" | grep "googleapi: Error"
                      if [ $? = 0 ]; then
                      USED=$(( $USED+$MINSA ))
                         if [[ "${USED}" -eq "${MAXSA}" ]]; then
                            USED=$MINSA && DIFF=1 && echo "${USED}" > "${LTKEY}"
                         fi
                      fi
                   done
                fi
           else
               DIFF=$DIFF && USED=${USED}
            fi
         rm -rf "${LOGFILE}/${FILE}.txt" "${START}/${FILE}.json" && chmod 755 "${DONE}/${FILE}.json"
      done
      rm -rf "${CHK}" && log "MOVE FINISHED from ${DLFOLDER} to REMOTE"
   else
      log "MOVE skipped || less then 1 file" && sleep 180
   fi
done
