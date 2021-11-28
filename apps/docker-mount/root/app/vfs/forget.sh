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
# environment
source /system/mount/mount.env
config=/app/rclone/rclone.conf
log=/system/mount/logs/vfs-forget.log

FORGET=$1
## FIRST FORGET

rclone rc vfs/forget dir="${FORGET}" \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS} \
--config=${config} --log-file=${log} \
--log-level=${LOGLEVEL_RC}

sleep 90

## THEN PULL
rclone rc vfs/refresh _async=true recursive=false dir="${FORGET}" \
--rc-user=${RC_USER} --rc-pass=${RC_PASSWORD} \
--rc-addr=localhost:${RC_ADDRESS} \
--config=${config} --log-file=${log} \
--log-level=${LOGLEVEL_RC}

truncate -s 0 ${log}

#EOF
