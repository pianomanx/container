#!/bin/bash

find ./base -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./base/${app}/latest-overlay.sh"; then
      version=$(bash "./base/${app}/latest-overlay.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
         echo "${version}" | tee "./base/${app}/OVERLAY_VERSION" > /dev/null
         echo "${app} ${version}"
      fi
   fi
 done

find ./base -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./base/${app}/latest-version.sh"; then
      version=$(bash "./base/${app}/latest-version.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
         echo "${version}" | tee "./base/${app}/VERSION" > /dev/null
         echo "${app} ${version}"
      fi
   fi
done

find ./apps -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | while read app; do
   if test -f "./apps/${app}/latest-version.sh"; then
      version=$(bash "./apps/${app}/latest-version.sh")
      if [[ ! -z "${version}" || "${version}" != "null" ]]; then
          echo "${version}" | tee "./apps/${app}/VERSION" > /dev/null
          echo "${app} ${version}"
      fi
   fi
done

if [[ -n $(git status --porcelain) ]]; then
   git config user.name "$GITHUB_ACTOR"
   git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
   git add -A
   git commit -sam "charges: add new release versions" || exit 0
   git push
fi

exit
