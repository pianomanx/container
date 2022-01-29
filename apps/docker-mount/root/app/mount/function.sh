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
CLOG=/system/mount/logs/vfs-clean.log
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

if [[ `cat "${MLOG}" | wc -l` -gt 0 ]]; then
   tail -n 20 "${MLOG}" | grep --line-buffered 'downloadQuotaExceeded' | while read ;do
       if [ $? = 0 ]; then
          if [[ ! ${DISCORD_SEND} != "null" ]]; then
             discord
          else
             log "${startuphitlimit}"
          fi
          if [[ ${ARRAY} != 0 ]]; then
             rotate && log "${startuprotate}"
          fi
       fi
   done
fi
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
   if [[ ! -d "${FDISCORD}" ]]; then
      mkdir -p "${FDISCORD}"
   fi
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
      echo "no changes" &>/dev/null
   fi

}

function lang() {

   LANGUAGE=${LANGUAGE}
   currenttime=$(date +%H:%M)

   if [[ ! -d "/app/language" ]]; then
      git -C /app clone --quiet https://github.com/dockserver/language.git
   fi
   if [[ "$currenttime" > "23:59" ]] || [[ "$currenttime" < "00:01" ]]; then
      if [[ -d "/app/language" ]]; then
         git -C "${LFOLDER}/" stash --quiet
         git -C "${LFOLDER}/" pull --quiet
         cd "${LFOLDER}/" && git stash clear
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
screen -d -m bash -c "rclone rcd --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} --cache-dir=${TMPRCLONE}";

}

function rcset() {

source /system/mount/mount.env

log ">> Set vfs options <<"
rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} \
--json '{ "vfs": { "CacheMaxSize": "'${VFS_CACHE_MAX_SIZE}'", "CacheMode": 3, "GID": '${PGID}',"UID": '${PUID}',"CaseInsensitive": false, "ChunkSize": "'${VFS_READ_CHUNK_SIZE}'", "ChunkSizeLimit": "'${VFS_READ_CHUNK_SIZE_LIMIT}'", "NoChecksum": false, "NoModTime": true, "NoSeek": true }}' &>/dev/null
sleep 5

log ">> Set mount  options <<"
rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} \
--json '{ "mount": { "AllowNonEmpty": true, "AllowOther": true, "AsyncRead": true, "Daemon": true ,"GID": 1000,"UID": 1000 }}' &>/dev/null
sleep 5

log ">> Set main options <<"
rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} \
--json '{ "main": { "LogLevel": 7, "BufferSize": "'${BUFFER_SIZE}'", "Checkers": 32, "UseListR": true, "UseMmap": true, "UseServerModTime": true, "TrackRenames": true, "UserAgent": "'${UAGENT}'" }}' &>/dev/null
sleep 5

log ">> Set log options <<"
rclone rc options/set --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} \
--json '{ "log": { "File": "'${MLOG}'", "Format": "date,time", "LogSystemdSupport": false }}'  &>/dev/null
sleep 5

}

function rcmount() {

source /system/mount/mount.env
fusermount -uzq ${REMOTE}
log ">> Starting mount <<"
rclone rc mount/mount --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} fs=remote: mountPoint="/mnt/unionfs" vfsOpt='{"GID": 1000,"UID": 1000}' &>/dev/null

}

function refreshVFS() {

source /system/mount/mount.env
log ">> run vfs refresh <<"
rclone rc vfs/refresh recursive=true --fast-list \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} \
--log-file=${RLOG} --log-level=${LOGLEVEL_RC} &>/dev/null

}

function rckill() {
log ">> kill it with fire <<"
source /system/mount/mount.env
rclone rc mount/unmount mountPoint=${REMOTE} \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG} &>/dev/null
fusermount -uzq ${REMOTE}

}

function rcclean() {

source /system/mount/mount.env
log ">> run fs cache clear <<"
rclone rc fscache/clear --fast-list \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--config=${CONFIG} --log-file=${CLOG} --log-level=${LOGLEVEL_RC}

}

function rcstats() {
# NOTE LATER
source /system/mount/mount.env
log ">> get rclone stats <<"
rclone rc core/stats --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} --config=${CONFIG}

}

function drivecheck() {

   mount=$(rclone rc mount/listmounts --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} | jq '.[] | .[] | .MountPoint')
   if [ "$(ls -A /mnt/unionfs)" ]; then
      rcclean && refreshVFS
   fi

}

function testrun() {

while true; do
   source /system/mount/mount.env
   if [ "$(ls -A /mnt/unionfs)" ]; then
      log "${startuprcloneworks}" && sleep 30
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
##  IF YOU DON'T KNOW WHAT YOU'RE DOING ##
##########################################
