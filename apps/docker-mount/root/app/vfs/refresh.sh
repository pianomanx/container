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

# environment
source /system/mount/mount.env
config=/app/rclone/rclone.conf
log=/system/mount/logs/vfs-refresh.log

rclone rc fscache/clear --fast-list \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS} \
--config=${config} --log-file=${log} \
--log-level=${LOGLEVEL_RC}

rclone rc vfs/refresh recursive=true --fast-list \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS} \
--config=${config} --log-file=${log} \
--log-level=${LOGLEVEL_RC}

truncate -s 0 ${log}
#EOF
