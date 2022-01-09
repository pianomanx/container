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
if pidof -o %PPID -x "$0"; then
    exit 1
fi

source /system/mount/mount.env
source /app/mount/function.sh

mkdir -p ${TMPRCLONE} ${REMOTE}

function rcx() {

rclone rc mount/mount \
   --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
   --config=${CONFIG} --cache-dir=${TMPRCLONE} \
   fs=remote: mountPoint=${REMOTE} mountType=mount \
   logOpt='{
   "File": "${MLOG}",
   "Format": "date,time",
   "LogSystemdSupport": false
   }'
   mainOpt='{
   "BufferSize": ${BUFFER_SIZE},
   "Checkers": 32,
   "TPSLimit": $[TPSLIMIT},
   "TPSLimitBurst": ${TPSBURST},
   "UseListR": true,
   "UseMmap": true,
   "UseServerModTime": true,
   "TrackRenames": true,
   "UserAgent": "${UAGENT}"
   }'
   vfsOpt='{
   "CacheMaxAge": ${VFS_CACHE_MAX_AGE},
   "CacheMaxSize": ${VFS_CACHE_MAX_SIZE},
   "CacheMode": 3,
   "CachePollInterval": ${VFS_CACHE_POLL_INTERVAL},
   "CaseInsensitive": false,
   "ChunkSize": ${VFS_READ_CHUNK_SIZE},
   "ChunkSizeLimit": ${VFS_READ_CHUNK_SIZE_LIMIT},
   "DirCacheTime": ${DIR_CACHE_TIME},
   "GID": ${PGID},
   "NoChecksum": false,
   "NoModTime": true,
   "NoSeek": true,
   "PollInterval": ${POLL_INTERVAL},
   "UID": ${PUID},
   "Umask": ${UMASK}
   }' 
   mountOpt='{
   "AllowNonEmpty": true,
   "AllowOther": true,
   "AsyncRead": true,
   "Daemon": true,
   "AllowOther": true
   }'

   rclone rc vfs/refresh recursive=true --fast-list \
   --rc-user=${RC_USER} \
   --rc-pass=${RC_PASSWORD} \
   --rc-addr=localhost:${RC_ADDRESS} \
   --config=${CONFIG} \
   --log-file=${RLLOG} \
   --log-level=${LOGLEVEL_RC}
}

function rckill() {
   rclone rc mount/unmount \
   mountPoint=${REMOTE} \
   --config=${CONFIG} \
   --rc-user=${RC_USER} \
   --rc-pass=${RC_PASSWORD} \
   --rc-addr=${RC_ADDRESS}
}

rclone rcd --rc-user=${RC_USER} \
  --rc-pass=${RC_PASSWORD} \
  --rc-addr=localhost:${RC_ADDRESS} \
  --cache-dir=${TMPRCLONE}

while true; do
   if [ "$(ls -A /mnt/unionfs)" ] && [ "$(ps aux | grep -i 'rclone rc mount/mount' | grep -v grep)" != "" ]; then
      sleep 360
   else
      rckill && sleep 10 && rcx && sleep 360
   fi
done

#EOF
