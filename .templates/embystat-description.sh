#!/usr/bin/env bash

DESCRIPTION="$(curl -u $username:$token -sX GET "https://api.github.com/repos/mregni/EmbyStat" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"

