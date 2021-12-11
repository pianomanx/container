#!/usr/bin/with-contenv bash

if grep -qs "PlexOnlineToken" "/config/Library/Application Support/Plex Media Server/Preferences.xml" || [ -z "$PLEX_CLAIM" ]; then
  echo "Plex Token is set"
else
   exit 0
fi

while :
 do
CURRTIME=`date +%s`
   export PLEXTOKEN=$(cat "/config/Library/Application Support/Plex Media Server/Preferences.xml" | sed -e 's;^.* PlexOnlineToken=";;' | sed -e 's;".*$;;' | tail -1)
   url="http://localhost:32400/status/sessions?X-Plex-Token=${PLEXTOKEN}"
   TEST=$(curl -LI "$url" -o /dev/null -w '%{http_code}\n' -s)
   export DIR=/mnt/unionfs
   if [[ $TEST -ge 200 && $TEST -le 299 ]]; then
      DIFF=$(($CURRTIME-$LASTRUN))
      if [[ "$(ls -A $DIR)" ]]; then
         if [ "$DIFF" -gt 86400 ] || [ "$DIFF" -lt 1 ] then
            LASTRUN=`date +%s`
            /usr/bin/python3� /app/plex-analyze-cli.py
         fi
      fi
     else
        sleep 300
     fi
     sleep 120
done 
