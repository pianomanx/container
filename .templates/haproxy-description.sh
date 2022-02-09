#!/usr/bin/env bash
username=$1
token=$2
DESCRIPTION="$(curl -u $username:$token -sX GET "https://api.github.com/repos/haproxy/haproxy" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"
