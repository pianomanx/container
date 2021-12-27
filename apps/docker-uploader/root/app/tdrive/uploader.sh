#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020 MrDoob
# All rights reserved.

# shellcheck disable=SC2003
# shellcheck disable=SC2006
# shellcheck disable=SC2207
# shellcheck disable=SC2012
# shellcheck disable=SC2086
# shellcheck disable=SC2196

function log() {
    echo "${1}"
}

path=/system/servicekeys/keys/
downloadpath=/mnt/downloads
#appbackups=/mnt/downloads/appbackups
MOVE_BASE=${MOVE_BASE:-/}
ENCRYPTED=${ENCRYPTED:-false}
if [[ "${ENCRYPTED}" == "false" ]]; then
    if grep -q GDSA1C /system/servicekeys/rclonegdsa.conf && grep -q GDSA2C /system/servicekeys/rclonegdsa.conf; then
        ENCRYPTED=true
    fi
fi
if [[ "${ENCRYPTED}" == "false" ]]; then
   DRIVE=TDrive
else
   DRIVE=TCrypt
fi

log "dockserver.io Uploader started"
rm -rf /app/uploader/pid/* \
       /system/uploader/vfsforget/* \
       /system/uploader/logs/* \
       /app/uploader/json/

find ${downloadpath} -type f -name '*.lck' -delete

GDSAARRAY=($(ls -1v ${path} | egrep '(PG|GD|GS)'))
# shellcheck disable=SC2003
GDSACOUNT=$(expr ${#GDSAARRAY[@]} - 1)
# shellcheck disable=SC2086

if [[ ${GDSACOUNT} -lt 1 ]]; then log "No accounts found to upload with, Exit" && exit 1; fi
if [[ -d "/system/uploader/.stored/" ]]; then rm -rf /system/uploader/.stored/ >/dev/null; fi
if [[ -d "/app/uploader" ]]; then chown -cR abc:abc /system/uploader/ 1>/dev/null 2>&1; fi

if [[ -d ${downloadpath} ]]; then
   mkdir -p ${downloadpath}/{torrent,nzb} &&  chown -cR 1000:1000 ${downloadpath} 1>/dev/null 2>&1
fi

if [[ -e "/system/uploader/.keys/lasteservicekey" ]]; then lastkeysused=$(cat /system/uploader/.keys/lasteservicekey); fi
if [[ -e "/system/uploader/.keys/usedupload" ]];then usedupload=$(cat /system/uploader/.keys/usedupload); fi
if [[ -e "/system/uploader/.keys/lastday" ]];then lastday=$(cat /system/uploader/.keys/lastday); fi
if [[ ! -e "/system/uploader/.keys/lasteservicekey" ]]; then lastkeysused=0; fi
if [[ ! -e "/system/uploader/.keys/usedupload" ]]; then usedupload=0; fi
if [[ ! -e "/system/uploader/.keys/lastday" ]]; then
   echo "0" >/system/uploader/.keys/lastday
fi

BI="! -wholename '**.anchor' ! -wholename '*partial~*' ! -wholename '*_HIDDEN~' ! -wholename '*.fuse_hidden*' ! -wholename '*.lck' ! -wholename '*.version'"
DI1="! -path '**.anchors/**' ! -path '**torrent/**' ! -path '**nzb/**' ! -path '**backup/**' ! -path '**nzbget/**' ! -path '**jdownloader2/**' ! -path '**sabnzbd/**'"
DI2="! -path '**rutorrent/**' ! -path '**deluge/**' ! -path '**qbittorrent/**' ! -path '**amd/**' ! -path '**aria/**' ! -path '**tubesync/**' ! -path '**-vpn/**'"
DI3="! -path '**_UNPACK_**' ! -path '**complete/**' ! -path '**torrents/**' ! -path '**temp/**' ! -path '.unionfs-fuse/*' ! -path '.unionfs/*' ! -path '**.inProgress/**'"

while true; do
    source /system/uploader/uploader.env
    if [[ ${DRIVEUSEDSPACE} != null ]]; then
       pathglobal=/mnt/downloads
       DRIVEPERCENT=$(df --output=pcent ${pathglobal} | tr -dc '0-9')
       TARCHECK=$(find ${downloadpath} -type f -cmin +${MIN_AGE_UPLOAD} -name "**.tar.**" | wc -l)
       while true; do
          if [[ ${TARCHECK} != 0 ]]; then
             sleep 1 && break
          elif [[ ${DRIVEPERCENT} -ge ${DRIVEUSEDSPACE} ]]; then
             sleep 1 && break
          else
             sleep 5 && continue
          fi
       done
    fi
    if [[ ${ADDITIONAL_IGNORES} == 'null' ]]; then ADDITIONAL_IGNORES=""; fi
    mapfile -t files < <(eval find ${downloadpath} -cmin +${MIN_AGE_UPLOAD} -type f $BI $DI1 $DI2 $DI3 ${ADDITIONAL_IGNORES})
    if [[ ${#files[@]} -gt 0 ]]; then
        for i in "${files[@]}"; do
            #mode chang for bypass double matched
            chmod 755 "${i}"
            FILEDIR=$(dirname "${i}" | sed "s#${downloadpath}${MOVE_BASE}##g")
            if [[ -e "${i}.lck" ]]; then
               log "Lock File found for ${i}" && continue
            else
                if [[ -e "${i}" ]]; then
                    FILESIZE1=$(stat -c %s "${i}")
                    sleep 1
                    FILESIZE2=$(stat -c %s "${i}")
                    if [[ "$FILESIZE1" -ne "$FILESIZE2" ]]; then
                       log "Lock File found for ${i}" && continue
                    fi
                    # shellcheck disable=SC2010
                    TRANSFERS=${TRANSFERS}
                    ACTIVETRANSFERS=$(ls -l /app/uploader/pid/ | egrep -c  '*.trans')
                    # shellcheck disable=SC2086
                    if [[ ! ${ACTIVETRANSFERS} -ge ${TRANSFERS} ]]; then
                        if [[ -e "${i}" ]]; then
                            last=$(echo "${lastday} + ${FILESIZE2}" | bc)
                            usedupload=$(echo "${usedupload} + ${FILESIZE2}" | bc)
                            if [ ${ENCRYPTED} == "true" ]; then
                                GDSA_TO_USE="${GDSAARRAY[$lastkeysused]}C"
                            else
                                GDSA_TO_USE="${GDSAARRAY[$lastkeysused]}"
                            fi
                            # Run upload script demonised
                            /app/uploader/upload.sh "${i}" "${GDSA_TO_USE}" &
                            PID=$!
                            FILEBASE=$(basename "${i}")
                            echo "${PID}" >"/app/uploader/pid/${FILEBASE}.trans"
                            if [[ ${usedupload} -gt "763831531520" ]]; then
                                log "${GDSAARRAY[$lastkeysused]} has hit 730GB switching to next SA"
                                if [ "${lastkeysused}" -eq "${GDSACOUNT}" ]; then
                                    lastkeysused=0
                                    usedupload=0
                                else
                                    lastkeysused=$(("${lastkeysused}" + 1))
                                    usedupload=0
                                fi
                                echo "${lastkeysused}" >/system/uploader/.keys/lasteservicekey
                            fi
                            log "${GDSAARRAY[${lastkeysused}]} is now $(echo "${usedupload}/1024/1024/1024" | bc -l) GiB"
                            echo "${last}" >/system/uploader/.keys/lastday
                            if [[ $(date +%H:%M) == "00:01" ]]; then
                                echo "0" >/system/uploader/.keys/lastday
                            else
                                log "Uploaded to ${DRIVE} = $(echo "${lastday}/1024/1024/1024" | bc -l) GiB since reset"
                             fi
                             echo "${usedupload}" >/system/uploader/.keys/usedupload
                        else
                            log "File ${i} seems to have dissapeared"
                        fi
                    else
                        log "Already ${ACTIVETRANSFERS} transfers running, waiting for next loop" && break
                    fi
                else
                    log "File not found: ${i}" && continue
                fi
            fi
        done
        log "Finished looking for files, sleeping 5 secs"
    else
        log "Nothing to upload or file age is not reached,sleeping 5 secs"
    fi
    sleep 5
done
#E-o-F#
