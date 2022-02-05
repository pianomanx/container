#!/usr/bin/env bash

DESCRIPTION="$(curl -u $username:$token -sX GET "https://api.github.com/repos/haproxy/haproxy" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"
