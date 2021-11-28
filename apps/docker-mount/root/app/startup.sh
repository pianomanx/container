#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#####################################
# All rights reserved.  #
# started from Zero  #
# Docker owned dockserver  #
# Docker Maintainer dockserver#
#####################################
#####################################
# THIS DOCKER IS UNDER LICENSE#
# NO CUSTOMIZING IS ALLOWED#
# NO REBRANDING IS ALLOWED #
# NO CODE MIRRORING IS ALLOWED#
#####################################
# shellcheck disable=SC2086
# shellcheck disable=SC2006
function log() {
	echo "[Mount] ${1}"
}
function ismounted() {
	mountpoint -q "$1"
}
function fusercommand() {
	fusermount -uzq "$1"
}
function checkban() {
	JSONDIR=/system/mount/keys
	SMOUNT=/app/mount
	GDSAARRAY=$(ls -l ${JSONDIR} | egrep -c '*.json')
	GDSAMIN=0
	SROTATE=${SMOUNT}/rotation.sh
	SCRIPT=${SMOUNT}/mount.sh
	logfile=$(grep -e "log" "${SCRIPT}" | sed "s#.*=##" | head -n1)
	tail -n 1 "${logfile}" | grep --line-buffered 'googleapi: Error' | while read; do
		if [[ ! ${DISCORD_SEND} != "null" ]]; then
			discord
		else
			log "${startuphitlimit}"
		fi
		if [[ ${GDSAARRAY} != 0 ]]; then
			chmod -cR 755 "${SROTATE}" && bash "${SROTATE}" && log "${startuprotate}"
		fi
	done
}

function discord() {
	source /system/mount/mount.env
	FDISCORD=/app/discord
	SDISCORD=${FDISCORD}/discord.sh
	DATE=$(date "+%Y-%m-%d")
	LOG="/tmp/discord.dead"
	JSONDIR=/system/mount/keys
	if [[ ${GDSAARRAY} != 0 ]]; then
		MSG1=${startuphitlimit}
		MSG2=${startuprotate}
		MSGSEND="${MSG1} and ${MSG2}"
		rm -rf ${LOG}
	else
		MSG1=${startuphitlimit}
		MSGSEND="${MSG1}"
	fi
	YEAR=$(date "+%Y")

	if [[ ! -d "${FDISCORD}" ]]; then mkdir -p "${FDISCORD}"; fi
	if [[ ! -f "${SDISCORD}" ]]; then
		curl --silent -fsSL https://raw.githubusercontent.com/ChaoticWeg/discord.sh/master/discord.sh -o "${SDISCORD}"
		chmod 755 "${SDISCORD}"
	fi
	if [[ ! -f "${LOG}" ]]; then
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
		--timestamp >${LOG}
	fi
}
function envrenew() {
	file1=/system/mount/mount.env
	file2=/tmp/mount.env
	diff -q "$file1" "$file2"
	RESULT=$?
	if [ $RESULT -gt 0 ]; then
		log "${startupnewchanges}"
		pkill -9 -f rclone
		ismounted /mnt/unionfs || fusercommand /mnt/unionfs
		ismounted /mnt/remotes || fusercommand /mnt/remotes
		ismounted ${TMPRCLONE} || fusercommand ${TMPRCLONE}
		SMOUNT=/app/mount
		find ${SMOUNT} -type f -iname "m*.sh" | while read file; do
			chmod -cR 755 "$file" && bash "$file" && rm -f "$file2" && cp "$file1" "$file2"
		done
	else
		rm -f /tmp/dead.lock && echo "no changes" >/tmp/dead.lock
	fi
}
function lang() {
	source /system/mount/mount.env
	LANGUAGE=${LANGUAGE}
	LFOLDER=/app/language/mount
	startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
	startuphitlimit=$(grep -Po '"startup.hitlimit": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
	startuprotate=$(grep -Po '"startup.rotate": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
	startupnewchanges=$(grep -Po '"startup.newchanges": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
	startuprcloneworks=$(grep -Po '"startup.rcloneworks": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')
	startupmergerfsworks=$(grep -Po '"startup.mergerfsworks": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')

	if [[ ! $(which git) ]]; then apk --quiet --no-cache --no-progress add git; fi
	currenttime=$(date +%H:%M)
	if [[ "$currenttime" > "23:59" ]] || [[ "$currenttime" < "00:01" ]]; then
		if [[ -d "/app/language" ]]; then
			git -C /app/language/ stash --quiet
			git -C /app/language/ pull --quiet
			cd /app/language/ && git stash clear
		fi
	fi
	if [[ ! -d "/app/language" ]]; then
		mkdir -p /app/language && git -C /app clone https://github.com/dockserver/language.git
	fi
}
function startup() {
	source /system/mount/mount.env
	ADDITIONAL_MOUNT=${ADDITIONAL_MOUNT}
	if [[ ${ADDITIONAL_MOUNT} != 'null' ]]; then
		if [[ -d ${ADDITIONAL_MOUNT} ]]; then fusercommand ${ADDITIONAL_MOUNT}; fi
	fi
	ismounted /mnt/unionfs || fusercommand /mnt/unionfs
	ismounted /mnt/remotes || fusercommand /mnt/remotes
	ismounted ${TMPRCLONE} || fusercommand ${TMPRCLONE}
	SMOUNT=/app/mount
	find ${SMOUNT} -type f -iname "m*.sh" | while read file; do
		chmod -cR 755 "$file" && bash "$file"
	done
}
#<COMMANDS>#
source /system/mount/mount.env
LANGUAGE=${LANGUAGE}
LFOLDER=/app/language/mount
startupmount=$(grep -Po '"startup.mount": *\K"[^"]*"' "${LFOLDER}/${LANGUAGE}.json" | sed 's/"\|,//g')

log "${startupmount}"
SMOUNT=/app/mount
mkdir -p /mnt/{remotes,unionfs}
ADDITIONAL_MOUNT=${ADDITIONAL_MOUNT}
if [[ ${ADDITIONAL_MOUNT} != 'null' ]]; then
	if [[ -d ${ADDITIONAL_MOUNT} ]]; then fusercommand ${ADDITIONAL_MOUNT}; fi
fi
ismounted /mnt/unionfs || fusercommand /mnt/unionfs
ismounted /mnt/remotes || fusercommand /mnt/remotes
ismounted ${TMPRCLONE} || fusercommand ${TMPRCLONE}
SMOUNT=/app/mount
find ${SMOUNT} -type f -iname "m*.sh" | while read file; do
	chmod -cR 755 "$file" && bash "$file"
done
sleep 5
## bypass prestart

#<ROTATION>#
RUNNINGRCLONE=$(pgrep rclone)
PROGRAMRCLONE=$(ps -e | grep "rclone" | grep -v grep | awk '{print $1;}')
RUNNINGMERGERFS=$(pgrep mergerfs)
PROGRAMMERGERFS=$(ps -e | grep "mergerfs" | grep -v grep | awk '{print $1;}')

while true; do
	if [[ "$PROGRAMRCLONE" != "$RUNNINGRCLONE" ]]; then
		pkill -9 -f rclone && startup
	else
		log "${startuprcloneworks}"
	fi
	if [[ "$PROGRAMMERGERFS" != "$RUNNINGMERGERFS" ]]; then
		pkill -9 -f mergerfs && startup
	else
		log "${startupmergerfsworks}"
	fi
	envrenew && lang && sleep 15 && checkban && continue
done

#<EOF>#
