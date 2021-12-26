#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020 MrDoob
# All rights reserved.
# Logging Function
function log() {
   echo "${1}"
}
source /system/uploader/uploader.env
downloadpath=/mnt/downloads
pathglobal=/mnt
IFS=$'\n'
FILE=$1
GDSA=$2
rjson=/system/servicekeys/rclonegdsa.conf
if grep -q GDSA1C "${rjson}" && grep -q GDSA2C "${rjson}"; then
   DRIVE=TCRYPT
else
   DRIVE=TDRIVE
fi
BANDWITHLIMIT=${BANDWITHLIMIT}
if [ "${BANDWITHLIMIT}" == 'null' ]; then
   BWLIMIT=""
else
   BANDWITHLIMIT=${BANDWITHLIMIT}
   BWLIMIT="--bwlimit=${BANDWITHLIMIT}"
fi

log "Upload started for $FILE using $GDSA to ${DRIVE}"
STARTTIME=$(date +%s)
FILEBASE=$(basename "${FILE}")
FILEDIR=$(dirname "${FILE}" | sed "s#${downloadpath}/##g")

VFS="/system/uploader/vfsforget/${FILEBASE}.json"
JSONFILEDONE="/system/uploader/json/done/${FILEBASE}.json"
JSONFILERUN="/system/uploader/json/upload/${FILEBASE}.json"
CHECKERS="$((${TRANSFERS} * 4))"
DISCORD="/app/uploader/discord/${FILEBASE}.discord"
PID="/app/uploader/pid"
echo "lock" >"${FILE}.lck"
HRFILESIZE=$(stat -c %s "${FILE}" | numfmt --to=iec-i --suffix=B --padding=7)
REMOTE=$GDSA
LOGFILE="/system/uploader/logs/${FILEBASE}.log"

echo "{\"filedir\": \"${FILEDIR}\",\"filebase\": \"${FILEBASE}\",\"filesize\": \"${HRFILESIZE}\",\"logfile\": \"${LOGFILE}\",\"gdsa\": \"${GDSA}\"}" >"${JSONFILERUN}"
touch "${JSONFILERUN}" && chmod 777 "${JSONFILERUN}" 1>/dev/null 2>&1
echo "{\"vfsforget\": \"${FILEDIR}\"}" >"${VFS}"
touch "${VFS}" && chmod 777 "${VFS}" 1>/dev/null 2>&1

touch "${LOGFILE}" && chmod 777 "${LOGFILE}" 1>/dev/null 2>&1
chown -cR 1000:1000 "${LOGFILE}" "${VFS}" "${JSONFILERUN}"  1>/dev/null 2>&1

rclone copyto --tpslimit=32 --checkers=${CHECKERS} \
   --config=${rjson} --log-file=${LOGFILE} --log-level=${LOG_LEVEL} --stats 1s \
   --drive-chunk-size=32M --user-agent=${USERAGENT} ${BWLIMIT} \
   "${FILE}" "${REMOTE}:${FILEDIR}/${FILEBASE}/${FILE}"

rclone check "${downloadpath}/${FILEDIR}/${FILEBASE}/${FILE}" "${REMOTE}:${FILEDIR}/${FILEBASE}/${FILE}" | \
f [ $? -eq 0 ]; then
   echo true
   ##rm -rf ${downloadpath}/${FILEDIR}/${FILEBASE}/${FILE}
else
   echo FAIL
fi

##rclone check "${downloadpath}/${FILEDIR}/${FILEBASE}/${FILE}" "${REMOTE}:${FILEDIR}/${FILEBASE}/${FILE}" | \
##rm -rf ${downloadpath}/${FILEDIR}/${FILEBASE}/${FILE}

ENDTIME=$(date +%s)

# shellcheck disable=SC2003
DRIVEPERCENT=$(df --output=pcent ${pathglobal} | tr -dc '0-9')
LEFTTOUPLOAD=$(du -sh ${downloadpath}/ --exclude={torrent,nzb,filezilla,backup,nzbget,jdownloader2,sabnzbd,rutorrent,deluge,qbittorrent} | awk '$2 == "/mnt/downloads/" {print $1}')
TIME="$((count = ${ENDTIME} - ${STARTTIME}))"
duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
SDISCORD=/app/scripts/discord.sh

rm -rf "${JSONFILERUN}" 1>/dev/null 2>&1
echo "{\"filedir\": \"${FILEDIR}\",\"filebase\": \"${FILEBASE}\",\"filesize\": \"${HRFILESIZE}\",\"gdsa\": \"${GDSA}\",\"starttime\": \"${STARTTIME}\",\"endtime\": \"${ENDTIME}\"}" >"${JSONFILEDONE}"
chown -cR 1000:1000 "${LOGFILE}" "${VFS}" "${JSONFILEDONE}" 1>/dev/null 2>&1

if [[ ${DISCORD_WEBHOOK_URL} != 'null' ]]; then
   bash ${SDISCORD} \
   --webhook-url=${DISCORD_WEBHOOK_URL} \
   --title "${DISCORD_EMBED_TITEL}" \
   --avatar "${DISCORD_ICON_OVERRIDE}" \
   --author "${DISCORD_NAME_OVERRIDE} Bot" \
   --author-url "https://dockserver.io" \
   --author-icon "https://dockserver.io/img/favicon.png" \
   --username "${DISCORD_NAME_OVERRIDE}" \
   --field "FILE;${DRIVE}/${FILEDIR}/${FILEBASE};true" \
   --field "SIZE;${HRFILESIZE}" \
   --field "DRIVE USED;${DRIVEPERCENT} %" \
   --field "Upload queue;${LEFTTOUPLOAD}Bytes" \
   --field "Time;${duration}" \
   --field "Active Transfers;${TRANSFERS}" \
   --thumbnail "https://upload.wikimedia.org/wikipedia/en/e/e4/Green_tick.png" \
   --footer "(c) 2021 DockServer.io" \
   --footer-icon "https://upload.wikimedia.org/wikipedia/en/e/e4/Green_tick.png" \
   --timestamp
else
   log "Upload complete for $FILE || Upload queue : ${LEFTTOUPLOAD}Bytes || Percent used: ${DRIVEPERCENT}%"
fi

rm -f "${FILE}.lck" "${LOGFILE}" "${PID}/${FILEBASE}.trans"

#<E-O-F>#
