#!/usr/bin/env bash
username=$1
token=$2
DESCRIPTION="$(curl -sX GET "https://api.github.com/repos/librespeed/speedtest" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"
