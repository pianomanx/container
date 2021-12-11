#!/usr/bin/with-contenv bash

if grep -qs "PlexOnlineToken" "/config/Library/Application Support/Plex Media Server/Preferences.xml" || [ -z "$PLEX_CLAIM" ]; then
  echo "Plex Token is set"
else
   exit 0
fi

LASTOPTIMIZE=`date +%s`

while :
 do
CURRTIME=`date +%s`
   export PLEXTOKEN=$(cat "/config/Library/Application Support/Plex Media Server/Preferences.xml" | sed -e 's;^.* PlexOnlineToken=";;' | sed -e 's;".*$;;' | tail -1)
   TEST=$(curl -LI "http://localhost:32400/system?X-Plex-Token=$PLEXTOKEN" -o /dev/null -w '%{http_code}\n' -s)
   export DIR=/mnt/unionfs
   if [[ $TEST -ge 200 && $TEST -le 299 ]]; then
      if [[ "$(ls -A $DIR)" ]]; then
         DIFF=$(($CURRTIME-$LASTOPTIMIZE))
         if [ "$DIFF" -gt 43200 ] || [ "$DIFF" -lt 1 ];then
            /usr/bin/python3 /app/plex-analyze-cli.py
         fi
      fi
     else
        sleep 300
     fi
     sleep 120
done 
