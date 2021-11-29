#!/bin/bash
####################################
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
# shellcheck disable=SC2046

find ./base -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./base/${app}/latest-overlay.sh"; then
      version=$(bash "./base/${app}/latest-overlay.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
         echo "${version}" | tee "./base/${app}/OVERLAY_VERSION" > /dev/null
         echo "${app} ${version}"
      fi
   fi
 done
sleep 5
find ./base -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./base/${app}/latest-version.sh"; then
      version=$(bash "./base/${app}/latest-version.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
         echo "${version}" | tee "./base/${app}/VERSION" > /dev/null
         echo "${app} ${version}"
      fi
   fi
done
sleep 5
find ./apps -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./apps/${app}/latest-version.sh"; then
      version=$(bash "./apps/${app}/latest-version.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
          echo "${version}" | tee "./apps/${app}/VERSION" > /dev/null
          echo "${app} ${version}"
      fi
   fi
done
sleep 5
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'Github Bot'
   git config --global user.email 'bot@users.noreply.github.com'
   git add -A
   git commit -sam "[Auto Generation] Adding new release version" || exit 0
   git push
fi

exit
