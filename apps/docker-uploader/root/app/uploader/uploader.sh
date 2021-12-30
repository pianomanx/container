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

log "dockserver.io Multi-Thread Uploader started"
rjson=/system/servicekeys/rclonegdsa.conf

if `rclone config show --config=${rjson} | grep ":/encrypt" &>/dev/null`;then CRYPTED=C;fi
if ! `rclone config show --config=${rjson} | grep "local" &>/dev/null`;then
   rclone config create down local nunc 'true' --config=${rjson}
fi

if `rclone config show --config=${rjson} | grep "GDSA" &>/dev/null`;then
  KEY=GDSA
elif `rclone config show --config=${rjson} | head -n1 | grep -Po '\[.*?]' | sed 's/.*\[\([^]]*\)].*/\1/' | sed '/GDSA/d'`;then
  KEY=""
else
  echo " no match found of GDSA[01=~100] or [01=~100]"
  sleep infinity
fi

path=/system/servicekeys/keys/
ARRAY=($(ls -1v ${path} | egrep '(PG|GD|GS|0)'))
COUNT=$(expr ${#ARRAY[@]} - 1)

if test -f "/system/uploader/.keys/lasteservicekey"; then
  used=$(cat /system/uploader/.keys/lasteservicekey)
  echo "${used}" | tee /system/uploader/.keys/lasteservicekey > /dev/null
else
  used=1 && echo "1" | tee /system/uploader/.keys/lasteservicekey > /dev/null
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

LOGFILE=rclone.json
START=/system/uploader/json/upload
DONE=/system/uploader/json/done
DIFF=/tmp/difflist.txt
CHK=/tmp/check.log
EXCLUDE=/system/uploader/rclone.exclude

while true;do 
   if [ "${used}" -eq "${COUNT}" ]; then
      used=1
   else
      used=${used}
   fi
   source /system/uploader/uploader.env
   TRANSFERS=${TRANSFERS}
   DRIVEUSEDSPACE=${DRIVEUSEDSPACE}
   BANDWITHLIMIT=${BANDWITHLIMIT}
   if [[ ! -z "${BANDWITHLIMIT}" ]]; then
      BWLIMIT=""
   else
      BWLIMIT="--bwlimit=${BANDWITHLIMIT}"
   fi
   pathglobal=/mnt/downloads
   local="down:${pathglobal}"
   DRIVEPERCENT=$(df --output=pcent ${pathglobal} | tr -dc '0-9')
   if [[ ! -z "${DRIVEUSEDSPACE}" ]]; then
      while true; do
        if [[ ${DRIVEPERCENT} -ge ${DRIVEUSEDSPACE} ]]; then
           sleep 1 && break
        else
           sleep 5 && continue
        fi
      done
   fi
   log "STARTING DIFFMOVE FROM LOCAL TO REMOTE"
   rm -f ${CHK} ${DIFF} ${START}/${LOGFILE}
   rclone check ${local} ${KEY}$[used]${CRYPTED}: --min-age=${MIN_AGE_UPLOAD}m \
     --size-only --one-way --fast-list --exclude-from=${EXCLUDE} > ${CHK} 2>&1
   awk 'BEGIN { FS = ": " } /ERROR/ {print $2}' ${CHK} > ${DIFF}
   num_files=`cat ${CHK} | wc -l`
   log "Number of files to be moved $num_files"
   [ $num_files -gt 0 ] && {
   sed '/^\s*#.*$/d' ${DIFF} | \
      while IFS=$'\n' read -r -a modu; do
          chown -cR 1000:1000 ${pathglobal}/${modu[0]} > /dev/null
      done
   log "STARTING RCLONE MOVE from ${local} to ${KEY}$[used]${CRYPTED}:"
   touch ${START}/${LOGFILE} 2>&1
   rclone move --files-from ${CHK} ${local} ${KEY}$[used]${CRYPTED}: --stats=10s \
     --drive-use-trash=false --drive-server-side-across-configs=true \
     --transfers ${TRANSFERS} --checkers=16 --use-mmap --cutoff-mode=soft \
     --use-json-log --log-file=${START}/${LOGFILE} --log-level=INFO \
     --user-agent=${USERAGENT} ${BWLIMIT} --config=${rjson}  \
     --max-backlog=20000000 --tpslimit 32 --tpslimit-burst 32
   mv ${START}/${LOGFILE} ${DONE}/${LOGFILE} 
   rm -f ${CHK} ${DIFF}; }
   log "DIFFMOVE FINISHED moving differential files from ${local} to GDSA$[used]${CRYPTED}:"
   used=$(("${used}" + 1))
   echo "${used}" | tee "/system/uploader/.keys/lasteservicekey" > /dev/null

sleep 60

done

##E-o-F##
