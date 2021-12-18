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

function fusercommand() {
    fusermount -uzq "$1"
}

# environment
source /system/mount/mount.env
CONFIG=/app/rclone/rclone.conf
log=/system/mount/logs/rclone-union.log

fusercommand /mnt/remotes

# rclone command

rclone mount remote: /mnt/remotes \
--config=${CONFIG} \
--log-file=${log} \
--log-level=${LOGLEVEL} \
--uid=${PUID} --gid=${PGID} --umask=${UMASK} \
--allow-other --allow-non-empty \
--timeout=1h --use-mmap \
--cache-dir=${TMPRCLONE} \
--tpslimit=${TPSLIMIT} --tpslimit-burst=${TPSBURST} \
--no-modtime --no-seek \
--drive-use-trash=${DRIVETRASH} \
--drive-stop-on-upload-limit \
--drive-server-side-across-configs \
--drive-acknowledge-abuse \
--ignore-errors --poll-interval=${POLL_INTERVAL} \
--user-agent=${UAGENT} --no-checksum \
--drive-chunk-size=${DRIVE_CHUNK_SIZE} \
--buffer-size=${BUFFER_SIZE} \
--dir-cache-time=${DIR_CACHE_TIME} \
--cache-info-age=${CACHE_INFO_AGE} \
--vfs-cache-poll-interval=${VFS_CACHE_POLL_INTERVAL} \
--vfs-cache-mode=${VFS_CACHE_MODE} \
--vfs-cache-max-age=${VFS_CACHE_MAX_AGE} \
--vfs-cache-max-size=${VFS_CACHE_MAX_SIZE} \
--vfs-read-chunk-size-limit=${VFS_READ_CHUNK_SIZE_LIMIT} \
--vfs-read-chunk-size=${VFS_READ_CHUNK_SIZE}
--rc --rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS} --daemon

#EOF
