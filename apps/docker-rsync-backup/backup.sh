#!/bin/sh
#########################################################
# Script to do rsync backups
# Adapted from script found on the rsync.samba.org
# Brian Hone 3/24/2002
# Updated 2015-10-09 by Johan Swetzén
# Adapted for Docker 2017-11-14 by Johan Swetzén
# This script is freely distributed under the GPL
#########################################################

# CRON_TIME (default: "0 1 * * *")
# - Time of day to do backup
# - Specified in Timezone

#########################################
# From here on out, you probably don't  #
#   want to change anything unless you  #
#   know what you're doing.             #
#########################################
function log() {
  echo "[Backup] `date '+%T %A %d-%B,%Y'` ${1}"
}
echo -e "plex/database/Library/Application Support/Plex Media Server/Cache/PhotoTranscoder
plex/database/Library/Application Support/Plex Media Server/Cache/Transcode
plex/database/Library/Application Support/Plex Media Server/Logs
plex/database/Library/Application Support/Plex Media Server/Crash Reports
plex/database/Library/Application Support/Plex Media Server/Metadata/*.bif
plex/database/Library/Application Support/Plex Media Server/Media/*.bif
plex/database/Library/Application Support/Plex Media Server/Metadata/*
plex/database/Library/Logs/Plex Media Server/
plex/database/Library/Application Support/Plex Media Server/Plug-ins
plex/database/Library/Logs/
plex/database/Library/Crash Reports/
plex/database/Library/Codecs/
plex/transcoding-temp
nzbget.log
radarr/logs
radarr/MediaCover/*
sonarr/logs
sonarr/MediaCover/*
lidarr/logs
lidarr/MediaCover/*
radarr4k/logs
radarr4k/MediaCover/*
sonarr4k/logs
sonarr4k/MediaCover/*
radarrhdr/logs
radarrhdr/MediaCover/*
sonarrhdr/logs
sonarrhdr/MediaCover/*
log
logs
Log
Logs
backup
backups
Backup
Backups
transcodes
Transcodes
*.bif
*.log
*.logs
*.tar
*.zip
*.pid
*.mounted
plexguide/
*.db-wal
*.db-shm" >/root/backup_excludes



PIDFILE=/var/run/backup.pid
BACKUP_RUNNING=/log/backup-running
LOGS=/log
RCCONFIG=/rclone/rclone.conf
INCREMENT=$(date +%Y-%m-%d)
RUNNER_COMMAND="--config /rclone/rclone.conf | tail -n 1 | awk '{print $2}'"
# Options to pass to rsync
OPTIONS="--force --ignore-errors --delete \
  --exclude-from='/root/backup_excludes' \
  --exclude-from='/backup_excludes' \
  -avzheP --numeric-ids --ignore-times \
  --compress-level=${RSYNC_COMPRESS_LEVEL}"

OPTIONSTAR="--warning=no-file-changed \
  --ignore-failed-read \
  --absolute-names --warning=no-file-removed \
  --exclude-backups --exclude-vcs --exclude-caches \
  --exclude-from=/root/backup_excludes \
  --exclude-from=/backup_excludes --use-compress-program=pigz"

OPTIONSRCLONE="--config /rclone/rclone.conf \
  --checkers=4 --transfers=4 \
  --no-traverse --fast-list \
  --log-file=${LOGS}/rclone.log \
  --log-level=INFO --stats=5s \
  --stats-file-name-length=0 \
  --tpslimit=10 --tpslimit-burst=10 \
  --drive-chunk-size=128M  \
  --drive-acknowledge-abuse=true \
  --drive-stop-on-upload-limit --use-mmap"

OPTIONSREMOVE="--config /rclone/rclone.conf \
  --checkers=4 --no-traverse --fast-list \
  --log-file=${LOGS}/rclone-remove.log \
  --log-level=INFO --stats=30s \
  --stats-file-name-length=0 \
  --tpslimit=10 --tpslimit-burst=10 \
  --drive-chunk-size=128M  \
  --drive-acknowledge-abuse=true \
  --use-mmap"

OPTIONSTCHECK="--config /rclone/rclone.conf"
DISCORD="${LOGS}/discord.discord"
DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}

####### FUNCTIONS START #######
 apk --quiet --no-cache --no-progress add \
    ca-certificates rsync openssh-client tar wget logrotate \
    shadow bash bc findutils coreutils openssl rclone \
    curl libxml2-utils tree pigz tzdata openntpd grep

DIR="! -path '**plex/**' ! -path '**emby/**' ! -path '**jellyfin/**' ! -path '**arr/**' ! -path '**uploader/**' ! -path '**mount/**'"
if [[ ! -d "/rclone" ]]; then
   mkdir -p /rclone
fi

if [[ ! -f "/rclone/rclone.conf" ]];then
   mkdir -p /rclone && find ${BACKUPDIR}/ -type f $DIR -iname "rclone.conf" -exec ln -sv "{}" /rclone/rclone.conf \;
   export RCCONFIG=/rclone/rclone.conf
fi

if [[ "${SERVER_ID}" == "NOT-SET" ]];then
   SERVER_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
fi

# Make sure our backup tree exists
if [ -d "${ARCHIVEROOT}" ]; then
  install -d "${ARCHIVEROOT}"
  log ": Installed ${ARCHIVEROOT}"
  chmod 777 "${ARCHIVEROOT}"
  log ": Permission set for ${ARCHIVEROOT} || passed"
else 
  install -d "${ARCHIVEROOT}"
  log ": Installed ${ARCHIVEROOT}"
  chmod 777 "${ARCHIVEROOT}"
  log ": Permission set for ${ARCHIVEROOT} || passed"
fi
# Make sure Log folder exist 
if [ -d "${LOGS}" ]; then
  install -d "${LOGS}"
  log ": $LOGS exist - done"
  chmod 777 "${LOGS}"
else 
  log ": $LOGS not exist - create runs"
  install -d "${LOGS}"
  log ": Installed $LOGS - done"
  chmod 777 "${LOGS}"
fi
# Send start message via Díscord 
if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
   rm -rf ${DISCORD} && touch ${DISCORD}
   log ": rsync docker started" >"${DISCORD}"
   msg_content=$(cat "${DISCORD}")
   TITEL="RSYNC BACKUP"
   DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
   DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
   DISCORD_WEBHOOK_URL=${DISCORD_WEBHOOK_URL}
   curl -H "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
 else
   log ": rsync docker started"
fi
# Make sure rclone.conf exist 
if [ -f $RCCONFIG ]; then
  log ": rclone config found | files will stored on your Google drive"
else
  log ": WARNING = no rclone.conf found"
  log ": WARNING = Backups not uploaded to any place"
  log ": WARNING = backups are always overwritten"
fi
remove_logs()
{
if [ -d ${LOGS} ]; then
   truncate -s 0 ${LOGS}/*.log
fi
}
rsync_log()
{
tail -n 2 ${LOGS}/rsync.log
}
# Our actual rsyncing function
do_rsync()
{
 # shellcheck disable=SC2086
 # shellcheck disable=SC2164
  rsync ${OPTIONS} -e "ssh -Tx -c aes128-gcm@openssh.com -o Compression=no -i ${SSH_IDENTITY_FILE} -p${SSH_PORT}" "${BACKUPDIR}/" "$ARCHIVEROOT" >> ${LOGS}/rsync.log
}
tar_gz()
{
 # shellcheck disable=SC2086
 # shellcheck disable=SC2164
 # shellcheck disable=SC2006
cd ${ARCHIVEROOT}
 for dir_tar in `find . -maxdepth 1 -type d | grep -v "^\.$" `; do
    log ": Tar Backup running for ${dir_tar}"
    tar ${OPTIONSTAR} -C ${dir_tar} -cvf ${dir_tar}.tar.gz ./ >> ${LOGS}/tar.log
    log ": Tar Backup of ${dir_tar} successfull"
 done
}
### left over remove before upload 
remove_folder()
{
# shellcheck disable=SC2086
# shellcheck disable=SC2164
# shellcheck disable=SC2006
cd ${ARCHIVEROOT}
 for dirrm in `find . -maxdepth 1 -type d | grep -v "^\.$" `; do
    log ": Remove folder running for ${dirrm}"
    rm -rf ${dirrm} >> ${LOGS}/removefolder.log
    log ": Remove folder of ${dirrm} successfull"
 done
}
### left over remove after upload
remove_tar()
{
# shellcheck disable=SC2086
# shellcheck disable=SC2164
# shellcheck disable=SC2006
cd ${ARCHIVEROOT}
 for tarrm in `find . -maxdepth 1 -type f | grep ".tar.gz" `; do
    log ": Remove running for ${tarrm}"
    rm -rf ${tarrm} >> ${LOGS}/removetar.log
    log ": Remove of ${tarrm} successfull"
 done
}
upload_tar()
{
# shellcheck disable=SC2164
# shellcheck disable=SC2086
# shellcheck disable=SC2164
if grep -q gcrypt /rclone/rclone.conf; then
   REMOTE="gcrypt"
elif grep -q tcrypt /rclone/rclone.conf; then
   REMOTE="tcrypt"
elif grep -q tdrive /rclone/rclone.conf; then
   REMOTE="tdrive"
elif grep -q gdrive /rclone/rclone.conf; then
   REMOTE="gdrive"
else
   REMOTE=""      
fi

if [[ ${REMOTE} != "" ]];then
   log ": Server ID set to ${SERVER_ID}"
   tree -a -L 1 ${ARCHIVEROOT} | awk '{print $2}' | tail -n +2 | head -n -2 | grep ".tar" >/tmp/tar_folders
   p="/tmp/tar_folders"
   while read p; do
      echo $p >/tmp/tar
      tar=$(cat /tmp/tar)
      rclone copyto ${ARCHIVEROOT}/${tar} ${REMOTE}:/backup/${SERVER_ID}/${tar} ${OPTIONSRCLONE}
      rclone moveto ${ARCHIVEROOT}/${tar} ${REMOTE}:/backup-daily/${SERVER_ID}/${INCREMENT}/${tar} ${OPTIONSRCLONE}
   done </tmp/tar_folders
else
   log "Unsupported Remotes found nothing uploaded"
fi
}
remove_old_backups()
{
# shellcheck disable=SC2164
# shellcheck disable=SC2086
# shellcheck disable=SC2164
if grep -q gcrypt /rclone/rclone.conf; then
   REMOTE="gcrypt"
elif grep -q tcrypt /rclone/rclone.conf; then
   REMOTE="tcrypt"
elif grep -q tdrive /rclone/rclone.conf; then
   REMOTE="tdrive"
elif grep -q gdrive /rclone/rclone.conf; then
   REMOTE="gdrive"
else
   REMOTE=""      
fi
if [[ ${REMOTE} != "" ]];then
   if [ $(rclone lsd ${REMOTE}:/backup-daily/${SERVER_ID} ${OPTIONSTCHECK} | wc -l) -lt ${BACKUP_HOLD} ]; then
      log ": Daily Backups on ${REMOTE} lower as ${BACKUP_HOLD} set"
   else
      rclone lsd ${REMOTE}:/backup-daily/${SERVER_ID} ${OPTIONSTCHECK} | head -n ${BACKUP_HOLD} | awk '{print $2}' >/tmp/backup_old
      p="/tmp/backup_old"
      while read p; do
         echo $p >/tmp/old_backups
         old_backup=$(cat /tmp/old_backups)
         rclone purge ${REMOTE}:/backup-daily/${SERVER_ID}/${old_backup} ${OPTIONSREMOVE}
      done </tmp/backup_old
   fi
else
   log "Unsupported Remotes found nothing uploaded"
fi
}
discord()
{
if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
  TRANSFERED=$(tail -n 2 ${LOGS}/rsync.log | awk '{printf "%s\\n",$0} END {print ""}')
  TIME="$((count=${ENDTIME}-${STARTTIME}))"
  duration="$(($TIME / 60)) minutes and $(($TIME % 60)) seconds elapsed."
  log ": \nTime : ${duration} \nBackup Complete \nTransfered: ${TRANSFERED}" >"${DISCORD}"
  msg_content=$(cat "${DISCORD}")
  TITEL="RSYNC BACKUP"
  DISCORD_ICON_OVERRIDE=${DISCORD_ICON_OVERRIDE}
  DISCORD_NAME_OVERRIDE=${DISCORD_NAME_OVERRIDE}
  DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"
  curl -H "Content-Type: application/json" -X POST -d "{\"username\": \"${DISCORD_NAME_OVERRIDE}\", \"avatar_url\": \"${DISCORD_ICON_OVERRIDE}\", \"embeds\": [{ \"title\": \"${TITEL}\", \"description\": \"$msg_content\" }]}" $DISCORD_WEBHOOK_URL
else
  log ": Backup complete"
fi
}
#####

function commando_start() {
touch $PIDFILE;
touch $BACKUP_RUNNING
STARTTIME=$(date +%s)
log ": remove old log files"
remove_logs
log ": Rsync Backup is starting"
do_rsync
log ": Rsync Backup done"
log ": $(rsync_log)"
tar_gz
log ": Tar Backup done"
  if [ -f $RCCONFIG ]; then
     log ": starting upload and remove backups"
     remove_folder
     log ": remove leftover folder >> done"
     upload_tar
     log ": upload of the backups >> done"
     remove_old_backups
     log ": purge old backups >> done"
     remove_tar
     log ": purge old tar files >> done"
  fi
  ENDTIME=$(date +%s)
  if [ ${DISCORD_WEBHOOK_URL} != 'null' ]; then
     discord
  fi
rm -rf $BACKUP_RUNNING
remove_logs
rm -rf $PIDFILE;
}

function restart() {
rm -rf $BACKUP_RUNNING
rm -rf $PIDFILE
commando_start
}

# Some error handling and/or run our backup and tar_create/tar_upload
if [[ -f $PIDFILE && $(ls -l /log | egrep -c 'backup-running') == "1" ]]; then
  restart
else
  commando_start
fi

exit

#E-O-F
