#!/usr/bin/env bash
username=$1
token=$2
DESCRIPTION="$(curl -sX GET "https://api.github.com/repos/jellyfin/jellyfin" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"
