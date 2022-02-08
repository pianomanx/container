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

folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//' | sed '/images/d' )

for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
      if test -f "./.templates/${app}-version.sh"; then
         NEWVERSION=$(bash "./.templates/${app}-version.sh" "${username}" "${token}" )
         if [ "${NEWVERSION}" != "null" ] && [ "${NEWVERSION}" != "" ] && [ -n "${NEWVERSION}" ] && [ ! -z "${NEWVERSION}" ]; then
            if [ ! -f "./$i/${app}/release.json" ] ; then
               touch "./$i/${app}/release.json"
            fi
            echo "Docker : ${app} | Version : ${NEWVERSION}"
            DESCRIPTION=$(jq -r '.description' < ./$i/${app}/release.json)
            APP=$(echo ${app} | sed "s#docker-##g" | sed "s#-nightly##g")
            if test -f "./.templates/${APP}-description.sh"; then
               DESCRIPTION=$(bash "./.templates/${APP}-description.sh" "${username}" "${token}" )
            fi
            BASEIMAGE=$(jq -r '.baseimage' < ./$i/${app}/release.json)
            BUILDDATE="$(date +%Y-%m-%d)"
            PACKAGES=$(jq -r '.packages' < ./$i/${app}/release.json)
            PICTURE="./images/${app}.png"

echo '{
   "appname": "'${app}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$i'/'${app}'",
   "newversion": "'${NEWVERSION}'",
   "builddate": "'${BUILDDATE}'",
   "baseimage": "'${BASEIMAGE}'",
   "packages": "'${PACKAGES}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${app}' to '${NEWVERSION}'",
   "user": "github-actions[bot]"
}' > "./$i/${app}/release.json"
         unset app NEWVERSION DESCRIPTION BUILDDATE PICTURE PACKAGES BASEIMAGE
         fi
      fi
   done
done

unset token username

##remove unwanted and add file
folder=$(ls -1p ./ | grep '/$' | sed 's/\/$//' | sed '/images/d' )
for i in ${folder[@]}; do
   find ./$i -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
     rm -rf ./$i/${app}/VERSION \
            ./$i/${app}/OVERLAY_VERSION \
            ./$i/${app}/PLATFORM \
            ./$i/${app}/.editorconfig \
            ./$i/${app}/latest-overlay.sh \
            ./$i/${app}/.trigger-ci \
            ./$i/${app}/.dockerignore
     ## hardcoded files inside
     if [ -d "./$i/${app}/root/" ] && [ ! -f "./$i/${app}/root/dockserver.txt" ]; then
        cp "./.github/dockserver.txt" "./$i/${app}/root/donate.txt"
     fi
     unset app
   done
done

sleep 5
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'github-actions[bot]'
   git config --global user.email 'github-actions[bot]@users.noreply.github.com'
   git repack -a -d --depth=5000 --window=5000
   git add -A && git commit -sam "[Auto Generation] Adding new release version" || exit 0
   git push --force
fi

exit 0
