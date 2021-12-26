#!/usr/bin/with-contenv bash
# shellcheck shell=bash
######################################################
# Copyright (c) 2021, MrDoob                         #
######################################################
# All rights reserved.                               #
# started from Zero                                  #
# Docker owned from MrDoob                           #
# some codeparts are copyed from sagen from 88lex    #
# sagen is under MIT License                         #
# Copyright (c) 2019 88lex                           #
#                                                    #
# CREDITS: The scripts and methods are based on      #
# ideas/code/tools from ncw, max, sk, rxwatcher,     #
# l3uddz, zenjabba, dashlt, mc2squared, storm,       #
# physk , plexguide and all missed once              #
######################################################
# shellcheck disable=SC2086
# shellcheck disable=SC2046

cat > /etc/apk/repositories << EOF; $(echo)
alpine repos#
http://dl-cdn.alpinelinux.org/alpine/edge/community/
http://dl-cdn.alpinelinux.org/alpine/edge/main/
http://dl-cdn.alpinelinux.org/alpine/edge/testing/
EOF

   apk --quiet --no-cache --no-progress update && \
   apk --quiet --no-cache --no-progress upgrade

   inst=(bc curl unzip shadow musl findutils coreutils aria2)
   apk add --quiet --no-cache --no-progress --virtual=build-dependencies ${inst[@]}

rclone_version=$(curl -sX GET "https://api.github.com/repos/rclone/rclone/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_^v__')

case "$(arch)" in
   x86_64)
      platform=linux-amd64
      rclone_file=rclone-v${rclone_version}-${platform}.zip
     ;;
   armv7l)
     platform=linux-armv7
     rclone_file=rclone-v${rclone_version}-linux-arm-v7.zip
     ;;
   aarch64)
     platform=linux-arm64
     rclone_file=rclone-v${rclone_version}-${platform}.zip
     ;;
   *)
     echo "[ERROR] unsupported arch $(arch), exit now"
     exit 1
     ;;
esac

aria2c -x2 -k1M -d /tmp -o rclone.zip https://downloads.rclone.org/v${rclone_version}/${rclone_file}
cd /tmp/ && unzip rclone.zip
cd /tmp/rclone-*
cp rclone /usr/local/bin/ \
  && rm -rf /tmp/rclone*
rm -rf /var/cache/apk/* /tmp/*

if [ -f "/system/rclone/.env" ] && [ -f "/system/rclone/.token" ]; then
   bash startup
fi
if [ ! -f "/system/rclone/.env" ] && [ ! -f "/system/rclone/.token" ]; then
   exit
fi

##E#O#F##
