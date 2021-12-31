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

## check if script running > true exit
if pidof -o %PPID -x "$0"; then
    exit 1
fi

log "dockserver.io Multi-Thread Uploader started"
CONFIG=/system/servicekeys/rclonegdsa.conf

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
DIFF=/system/uploader/difflist.txt
CHK=/system/uploader/check.log
DOWN=/mnt/downloads

while true;do 
   if [ "${used}" -eq "${COUNT}" ]; then
      used=1
   else
      used=${used}
   fi
   source /system/uploader/uploader.env
   DRIVEUSEDSPACE=${DRIVEUSEDSPACE}
   BANDWITHLIMIT=${BANDWITHLIMIT}
   SRC="down:${DOWN}"
   DRIVEPERCENT=$(df --output=pcent ${DOWN} | tr -dc '0-9')
   if [[ ! -z "${BANDWITHLIMIT}" ]];then BWLIMIT="";fi
   if [[ -z "${BANDWITHLIMIT}" ]];then BWLIMIT="--bwlimit=${BANDWITHLIMIT}";fi
   if [[ ! -z "${DRIVEUSEDSPACE}" ]]; then
      while true; do
        if [[ ${DRIVEPERCENT} -ge ${DRIVEUSEDSPACE} ]]; then
           sleep 1 && break
        else
           sleep 5 && continue
        fi
      done
   fi
   log "CHECKING DIFFMOVE FROM LOCAL TO REMOTE"
   rm -f "${CHK}" "${DIFF}"
   echo "${KEY}$[used]${CRYPTED}"
   rclone check ${SRC} ${KEY}$[used]${CRYPTED}: --min-age=${MIN_AGE_UPLOAD}m \
     --size-only --one-way --fast-list --config=${CONFIG} --exclude-from=${EXCLUDE} > "${CHK}" 2>&1
   awk 'BEGIN { FS = ": " } /ERROR/ {print $2}' "${CHK}" > "${DIFF}"
   awk 'BEGIN { FS = ": " } /NOTICE/ {print $2}' "${CHK}" >> "${DIFF}"
   sed -i '1d' "${DIFF}" && sed -i '/Encrypted/d' "${DIFF}" && sed -i '/Failed/d' "${DIFF}"
   num_files=`cat ${DIFF} | wc -l`
   if [ $num_files -gt 0 ]; then
      log "STARTING RCLONE MOVE from ${SRC} to ${KEY}$[used]${CRYPTED}:"
      ##echo "${KEY}$[used]${CRYPTED}"
      sed '/^\s*#.*$/d' "${DIFF}" | \
      while IFS=$'\n' read -r -a upp; do
        echo "${DOWN}/${upp[0]}"
        touch "${START}/${upp[0]}"
        rclone moveto "${DOWN}/${upp[0]}" "${KEY}$[used]${CRYPTED}:/${upp[0]}" --config=${CONFIG} \
           --stats=10s --checkers=16 --use-json-log --use-mmap --update \
           --cutoff-mode=soft --log-level=INFO --user-agent=${USERAGENT} ${BWLIMIT} \
           --log-file="${START}/${upp[0]}" --log-level=INFO --tpslimit 50 --tpslimit-burst 50
      mv "${START}/${upp[0]}" "${DONE}/${upp[0]}"
      done
      log "DIFFMOVE FINISHED moving differential files from ${SRC} to ${KEY}$[used]${CRYPTED}:"
      used=$(("${used}" + 1))
      echo "${used}" | tee "/system/uploader/.keys/lasteservicekey" > /dev/null
   else
      log "DIFFMOVE FINISHED skipped || less then 1 file"
      sleep 60
   fi
done

##E-o-F##
