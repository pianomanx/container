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

export username=${username}
export token=${token}

##folder="apps base nightly"

folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//')

echo "${folder}"
sleep 5

for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
      if test -f "./$i/${app}/latest-overlay.sh"; then
         version=$(bash "./$i/${app}/latest-overlay.sh")        
         if [[ ! -z "${version}" || "${version}" != "" || "${version}" != 'null' ]]; then
            echo "${version}" | tee "./$i/${app}/OVERLAY_VERSION" > /dev/null
            echo "${app} ${version}"
            unset version
         else
            ##cat "./$i/${app}/OVERLAY_VERSION" | tee "./$i/${app}/OVERLAY_VERSION" > /dev/null
            echo "${app} failed to update"
            unset version
         fi
      fi
   done
done

folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//')

for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
      if test -f "./$i/${app}/latest-version.sh"; then
         version=$(bash "./$i/${app}/latest-version.sh")
         if [[ ! -z "${version}" || "${version}" != "" || "${version}" != 'null' ]]; then
            echo "${version}" | tee "./$i/${app}/VERSION" > /dev/null
            echo "${app} ${version}"
            unset version
         else
            ##cat "./$i/${app}/VERSION" | tee "./$i/${app}/VERSION" > /dev/null
            echo "${app} failed to update"
            unset version
         fi
      fi
   done
done

unset token
unset username

sleep 5
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'github-actions[bot]'
   git config --global user.email 'github-actions[bot]@users.noreply.github.com'
   git repack -a -d --depth=5000 --window=5000
   git add -A
   git commit -sam "[Auto Generation] Adding new release version" || exit 0
   git push
fi

exit
