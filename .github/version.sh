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
            DESCRIPTION=$(jq -r '.description' < ./$i/${app}/release.json)
            APP=$(echo ${app} | sed "s#docker-##g" | sed "s#-nightly##g")
            if test -f "./.templates/${APP}-description.sh"; then
               if [ "${DESCRIPTION}" == "" ] && [ "${DESCRIPTION}" == "null" ]; then
                  DESCRIPTION=$(bash "./.templates/${APP}-description.sh" "${username}" "${token}" )
               fi
            fi
            echo "${DESCRIPTION}"
            sleep 1
            OLDVERSION=$(jq -r '.newversion' < ./$i/${app}/release.json)
            if [ "${OLDVERSION}" != "${NEWVERSION}" ] && [ "${OLDVERSION}" == "${NEWVERSION}" ]; then
               BUILDDATE="$(date +%Y-%m-%d)"
            else
               BUILDDATE=$(jq -r '.builddate' < ./$i/${app}/release.json)
            fi
            echo "Docker : ${app} | Version : ${NEWVERSION}"
            if [[ -f "./images/${app}.png" ]]; then
               PICTURE="./images/${app}.png"
            else
               PICTURE="./images/image.png"
            fi
            if [ "${OLDVERSION}" != "${NEWVERSION}" ] ; then
echo -e '{
   "appname": "'${app}'",
   "apppic": "'${PICTURE}'",
   "appfolder": "./'$i'/'${app}'",
   "newversion": "'${NEWVERSION}'",
   "oldversion": "'${OLDVERSION}'",
   "builddate": "'${BUILDDATE}'",
   "description": "'${DESCRIPTION}'",
   "body": "Upgrading '${app}' from '${OLDVERSION}' to '${NEWVERSION}'",
   "user": "github-actions[bot]"
}' > "./$i/${app}/release.json"
fi
         rm -rf ./$i/${app}/VERSION \
             ./$i/${app}/OVERLAY_VERSION \
             ./$i/${app}/PLATFORM \
             ./$i/${app}/.editorconfig \
             ./$i/${app}/latest-overlay.sh
            unset OLDVERSION NEWVERSION DESCRIPTION BUILDDATE PICTURE
         fi
      fi
   done
done

unset token username

sleep 5
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'github-actions[bot]'
   git config --global user.email 'github-actions[bot]@users.noreply.github.com'
   git repack -a -d --depth=5000 --window=5000
   git add -A && git commit -sam "[Auto Generation] Adding new release version" || exit 0
   git push --force
fi

exit 0
