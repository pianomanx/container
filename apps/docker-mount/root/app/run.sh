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
function log() {
    echo "[Mount] ${1}"
}
umask 022

log "-> Starting mounts <-"
startup="/app/startup.sh"
sleep 5
log "-> Starting log purging in auto mode <-"
lpurge="/app/mount/log.sh"
sleep 5
log "-> Starting vfs refresh auto mode <-"
vfsrefresh="/app/mount/vfsrefresh.sh"
sleep 5
log "-> Starting nzb cleanup in auto mode <-"
nzb="/app/mount/nzbcleanup.sh"
sleep 5
log "-> Starting System <-"

bash $startup
bash $lpurge 
bash $vfsrefresh 
bash $nzb
