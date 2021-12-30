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

log "dockserver.io Uploader started"
rm -rf /app/uploader/pid/ \
       /system/uploader/vfsforget/ \
       /system/uploader/logs/ \
       /app/uploader/json/

find ${downloadpath} -type f -name '*.lck' -delete

rjson=/system/servicekeys/rclonegdsa.conf
if `rclone config show --config=${rjson} | grep ":/encrypt" &>/dev/null`;then CRYPTED=C;fi
if ! `rclone config show --config=${rjson} | grep "local" &>/dev/null`;then
   rclone config create down local nunc 'true' --config=${rjson}
fi

path=/system/servicekeys/keys/
ARRAY=($(ls -1v ${path} | egrep '(PG|GD|GS)'))
COUNT=$(expr ${#ARRAY[@]} - 1)

if [[ ! -f "/system/uploader/.keys/lasteservicekey" ]]; then
  used=0
else
  used=$(cat /system/uploader/.keys/lasteservicekey)
fi

if [[ ! -f /system/uploader/rclone.exclude ]]; then
   cat > /system/uploader/rclone.exclude << EOF; $(echo)
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

LOGFILE=/tmp/rclone.json
DIFF=/tmp/difflist.txt
CHK=/tmp/check.log
EXCLUDE=/system/uploader/rclone.exclude

while true;do 
   re='^[0-9]+$'
   if [ "${used}" -eq "${COUNT}" ]; then
      used=1
   else
      used=${used}
   fi

   source /system/uploader/uploader.env
   TRANSFERS=${TRANSFERS}
   DRIVEUSEDSPACE=${DRIVEUSEDSPACE}
   BANDWITHLIMIT=${BANDWITHLIMIT}

   if ! [ ${BANDWITHLIMIT} =~ $re ]; then
      BWLIMIT=""
   else
      BANDWITHLIMIT=${BANDWITHLIMIT}
      BWLIMIT="--bwlimit=${BANDWITHLIMIT}"
   fi

   pathglobal=/mnt/downloads
   local="down:${pathglobal}"

   DRIVEPERCENT=$(df --output=pcent ${pathglobal} | tr -dc '0-9')
   if [[ ${DRIVEUSEDSPACE} =~ $re ]]; then
      while true; do
        if [[ ${DRIVEPERCENT} -ge ${DRIVEUSEDSPACE} ]]; then
           sleep 1 && break
        else
           sleep 5 && continue
        fi
      done
   fi
   log "STARTING DIFFMOVE FROM LOCAL TO REMOTE"
   rm -f ${CHK} ${DIFF} ${LOGFILE}
   set -x
   rclone check ${local} GDSA$[used]${CRYPTED}: --min-age=10m \
     --size-only --one-way --fast-list \
     --exclude-from=${EXCLUDE} > ${CHK} 2>&1
   set +x
   awk 'BEGIN { FS = ": " } /ERROR/ {print $2}' check.log > ${DIFF}
   num_files=`cat ${CHK} | wc -l`
   log "Number of files to be moved $num_files"
   [ $num_files -gt 0 ] && {
   log "STARTING RCLONE MOVE from ${local} to GDSA$[used]${CRYPTED}:"
   touch ${LOGFILE} 2>&1
   rclone move --files-from ${CHK} ${local} GDSA$[used]${CRYPTED}: --stats=10s \
     --drive-use-trash=false --drive-server-side-across-configs=true \
     --transfers ${TRANSFERS} --checkers=16 --use-mmap --cutoff-mode=soft \
     --use-json-log --log-file=${LOGFILE} --log-level=INFO \
     --user-agent=${USERAGENT} ${BWLIMIT} --config=${rjson}  \
     --max-backlog=2000 --tpslimit 32 --tpslimit-burst 32
   rm -f ${CHK} ${DIFF} ${LOGFILE} ; }
   log "DIFFMOVE FINISHED moving differential files from ${local} to GDSA$[used]${CRYPTED}:"
   used=$(("${used}" + 1))
   echo ${used} > /opt/appdata/system/uploader/.keys/lasteservicekey

sleep 60

done

##E-o-F##
