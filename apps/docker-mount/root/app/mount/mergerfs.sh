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
# shellcheck disable=SC2006
function log() {
   echo "[Mount] ${1}"
}
if pidof -o %PPID -x "$0"; then
   exit 1
fi
#<COMMANDS>#
if [[ -f "/tmp/rclone-mount.file" ]]; then
   rm -f /tmp/rclone-mount.file
fi
source /system/mount/mount.env
ADDITIONAL_MOUNT=${ADDITIONAL_MOUNT}
ADDITIONAL_MOUNT_PERMISSION=${ADDITIONAL_MOUNT_PERMISSION}
if [[ ${ADDITIONAL_MOUNT} != 'null' ]]; then
   echo -n "/mnt/downloads=RW:${ADDITIONAL_MOUNT}=${ADDITIONAL_MOUNT_PERMISSION}:/mnt/remotes=NC" >>/tmp/rclone-mount.file
else
   echo -n "/mnt/downloads=RW:/mnt/remotes=NC" >>/tmp/rclone-mount.file
fi
UFSPATH=$(cat /tmp/rclone-mount.file)
rm -rf /tmp/mergerfs_mount_file && touch /tmp/mergerfs_mount_file
echo -e "allow_other,rw,async_read=false,use_ino,func.getattr=newest,category.action=all,category.create=mspmfs,cache.files=auto-full,dropcacheonclose=true,nonempty,minfreespace=0,fsname=mergerfs" >>/tmp/mergerfs_mount_file
MGFS=$(cat /tmp/mergerfs_mount_file)

mergerfs -o ${MGFS} ${UFSPATH} /mnt/unionfs

#<EOF>#
