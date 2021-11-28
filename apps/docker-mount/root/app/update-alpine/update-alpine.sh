#!/usr/bin/with-contenv bash
# shellcheck shell=bash
function log() {
    echo "[UPDATE] ${1}"
}

source /system/mount/mount.env
LANGUAGE=${LANGUAGE}
LFOLDER=/app/language/mount
CONFIG=/app/rclone/rclone.conf

updaterclonestart=$(grep -Po '"update.rclonestart": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
updatercloneendt=$(grep -Po '"update.rcloneend": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
updatepackagesstart=$(grep -Po '"update.packagesstart": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
updatepackagesend=$(grep -Po '"update.packagesend": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')

####
# function source start
log "${updaterclonestart}"

if [[ $(which rclone) ]]; then
    $(which rclone) selfupdate --config=${CONFIG} --stable
    chown -cf abc:abc /root/
fi
log "${updatercloneend}"

log "${updatepackagesstart}"
update="update upgrade fix"
for up2 in ${update}; do
    apk --quiet --no-cache --no-progress $up2
done
apk del --quiet --clean-protected --no-progress
rm -rf /var/cache/apk/*
log "${updatepackagesend}"

#<EOF>#
