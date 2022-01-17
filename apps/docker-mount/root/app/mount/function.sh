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
## FUNCTIONS SOURCECONFIG ##
#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################

source /system/mount/mount.env

#SETTINGS
CONFIG=/app/rclone/rclone.conf
ENVA=/system/mount/mount.env
TMPENV=/tmp/mount.env
GDSAMIN=4
ARRAY=$(ls -A ${JSONDIR} | wc -l )

#SCRIPTS
SROTATE=/app/mount/rotation.sh
SDISCORD=/app/discord/discord.sh

#FOLDER
REMOTE=/mnt/unionfs
JSONDIR=/system/mount/keys
SMOUNT=/app/mount
FDISCORD=/app/discord
LFOLDER=/app/language/mount

#LOG
MLOG=/system/mount/logs/rclone-union.log
RLOG=/system/mount/logs/vfs-refresh.log
DLOG=/tmp/discord.dead

#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################

function log() {

   echo "[Mount] ${1}"

}

function checkban() {

   tail -Fn0 "${MLOG}" | while read line ; do
   echo "$line" | grep "downloadQuotaExceeded"
       if [ $? = 0 ]; then
          if [[ ! ${DISCORD_SEND} != "null" ]]; then
             discord
          else
             log "${startuphitlimit}"
          fi
          if [[ ${ARRAY} != 0 ]]; then rotate && log "${startuprotate}" ; fi
       fi
   done

}

function rotate() {

if [[ ! -d "/system/mount/.keys" ]]; then
   mkdir -p /system/mount/.keys/ && chown -cR 1000:1000 /system/mount/.keys/ &>/dev/null
else
   chown -cR 1000:1000 /system/mount/.keys/ &>/dev/null
fi

if [[ ! -f /system/mount/.keys/lastkey ]]; then
   FMINJS=1
else
   FMINJS=$(cat /system/mount/.keys/lastkey)
fi

MINJS=${FMINJS}
MAXJS=${ARRAY}
COUNT=$MINJS

if `ls -A ${JSONDIR} | grep "GDSA" &>/dev/null`;then
    export KEY=GDSA
elif `ls -A ${JSONDIR} | head -n1 | grep -Po '\[.*?]' | sed 's/.*\[\([^]]*\)].*/\1/' | sed '/GDSA/d'`;then
    export KEY=""
else
   log "no match found of GDSA[01=~100] or [01=~100]"
   sleep 5
fi
if [[ "${ARRAY}" -eq "0" ]]; then
   log " NO KEYS FOUND "
else
   log "-->> We switch the ServiceKey to ${GDSA}${COUNT} "
   IFS=$'\n'
   filter="$1"
   mapfile -t mounts < <(eval rclone listremotes --config=${CONFIG} | grep "$filter" | sed -e 's/://g' | sed '/ADDITIONAL/d'  | sed '/downloads/d'  | sed '/crypt/d' | sed '/gdrive/d' | sed '/union/d' | sed '/remote/d' | sed '/GDSA/d')
   for i in ${mounts[@]}; do
       rclone config update $i service_account_file ${GDSA}$MINJS.json --config=${CONFIG}
       rclone config update $i service_account_file_path $JSONDIR --config=${CONFIG}
   done

   log "-->> Rotate to next ServiceKey done || MountKey is now ${GDSA}${COUNT} "
   if [[ "${ARRAY}" -eq "${COUNT}" ]]; then
      COUNT=1
   else
      COUNT=$(($COUNT >= $MAXJS ? MINJS : $COUNT + 1))
   fi
   COUNT=${COUNT}
   echo "${COUNT}" >/system/mount/.keys/lastkey
   cp -r /app/rclone/rclone.conf /root/.config/rclone/ && sleep 5 || exit 1
   log "-->> Next possible ServiceKey is ${GDSA}${COUNT} "
fi

}

function discord() {

   source /system/mount/mount.env
   DATE=$(date "+%Y-%m-%d")
   YEAR=$(date "+%Y")

   if [[ ${ARRAY} -gt 0 ]]; then
       MSG1=${startuphitlimit}
       MSG2=${startuprotate}
       MSGSEND="${MSG1} and ${MSG2}"
       rm -rf ${DLOG}
   else
       MSG1=${startuphitlimit}
       MSGSEND="${MSG1}"
   fi

   if [[ ! -d "${FDISCORD}" ]]; then mkdir -p "${FDISCORD}" : fi

   if [[ ! -f "${SDISCORD}" ]]; then
      curl --silent -fsSL https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh -o "${SDISCORD}" && chmod 755 "${SDISCORD}"
   fi

   if [[ ! -f "${DLOG}" ]]; then
      bash "${SDISCORD}" \
      --webhook-url=${DISCORD_WEBHOOK_URL} \
      --title "${DISCORD_EMBED_TITEL}" \
      --avatar "${DISCORD_ICON_OVERRIDE}" \
      --author "Dockerserver.io Bot" \
      --author-url "https://dockserver.io/" \
      --author-icon "https://dockserver.io/img/favicon.png" \
      --username "${DISCORD_NAME_OVERRIDE}" \
      --description "${MSGSEND}" \
      --thumbnail "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --footer "(c) ${YEAR} DockServer.io" \
      --footer-icon "https://www.freeiconspng.com/uploads/error-icon-4.png" \
      --timestamp > "${DLOG}"
   fi

}

function envrenew() {

   diff -q "$ENVA" "$TMPENV"
   if [ $? -gt 0 ]; then
      rckill && rcset && rcmount && cp -r "$ENVA" "$TMPENV"
    else
      echo "no changes" > "${NLOG}"
   fi

}

function lang() {

   LANGUAGE=${LANGUAGE}
   currenttime=$(date +%H:%M)

   if [[ ! -d "/app/language" ]]; then mkdir -p "${LFOLDER}/" && git -C /app clone https://github.com/dockserver/language.git ; fi
   if [[ "$currenttime" > "23:59" ]] || [[ "$currenttime" < "00:01" ]]; then
      if [[ -d "/app/language" ]]; then
         git -C "${LFOLDER}/" stash --quiet && git -C "${LFOLDER}/" pull --quiet && cd "${LFOLDER}/" && git stash clear
      fi
   fi

   startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuphitlimit=$(grep -Po '"startup.hitlimit": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprotate=$(grep -Po '"startup.rotate": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startupnewchanges=$(grep -Po '"startup.newchanges": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
   startuprcloneworks=$(grep -Po '"startup.rcloneworks": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')

}

function rcstart() {

source /system/mount/mount.env
screen -d -m bash -c "rclone rcd --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --cache-dir=${TMPRCLONE}";

}

function rcset() {

source /system/mount/mount.env

rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--json '{"vfs": {"CacheMaxSize": "'${VFS_CACHE_MAX_SIZE}'", "CacheMode": 3, "CaseInsensitive": false, "ChunkSize": "'${VFS_READ_CHUNK_SIZE}'", "ChunkSizeLimit": "'${VFS_READ_CHUNK_SIZE_LIMIT}'", "NoChecksum": false, "NoModTime": true, "NoSeek": true}}'

rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--json '{"mount": {"AllowNonEmpty": true, "AllowOther": true, "AsyncRead": true, "Daemon": true, "AllowOther": true }}'

rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--json '{"main": { "LogLevel": 10 ,"BufferSize": "'${BUFFER_SIZE}'", "Checkers": 32, "TPSLimit": "'${TPSLIMIT}'", "TPSLimitBurst": "'${TPSBURST}'", "UseListR": true, "UseMmap": true, "UseServerModTime": true, "TrackRenames": true, "UserAgent": "'${UAGENT}'" }}'

rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--json '{"log": {"File": "'${MLOG}'", "Format": "date,time", "LogSystemdSupport": false }}'

}

function rcmount() {

source /system/mount/mount.env
fusermount -uzq ${REMOTE}
rclone rc mount/mount --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} fs=remote: mountPoint="'${REMOTE}'"

}

function refreshVFS() {

source /system/mount/mount.env
rclone rc vfs/refresh recursive=true \
--fast-list --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--log-file=${RLLOG} --log-level=${LOGLEVEL_RC}

}

function rckill() {

source /system/mount/mount.env
rclone rc mount/unmount mountPoint=${REMOTE} \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD}
fusermount -uzq ${REMOTE}

}

function rcclean() {

source /system/mount/mount.env
rclone rc fscache/clear --fast-list \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--log-file=${RLOG} --log-level=${LOGLEVEL_RC}

}

function rcstats() {
# NOTE LATER
source /system/mount/mount.env
rclone rc core/stats --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD}

}

function rctest() {

source /system/mount/mount.env
mount=$(rclone rc mount/listmounts --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} | jq '.[] | .[] | .MountPoint')

}

function drivecheck() {

   mount=$(rclone rc mount/listmounts --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} | jq '.[] | .[] | .MountPoint')

   if [ "$(ls -A /mnt/unionfs)" ] && [ "${mount}" == "${REMOTE}" ]; then
      rcclean && refreshVFS
   fi

}

function testrun() {

while true; do
   rctest
   if [ "$(ls -A ${REMOTE})" ] && [ "${mount}" == "${REMOTE}" ]; then
      log "${startuprcloneworks}"
   else
      rckill && rcset && rcmount && rcclean
   fi
   envrenew && lang && sleep 360 && checkban
done

}

#########################################
# Till here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
     ### DO NOT MAKE ANY CHANGES ###
### IF YOU DON'T KNOW WHAT YOU'RE DOING ###
