#!/usr/bin/env bash
DESCRIPTION="$(curl -u $username:$token -sX GET "https://api.github.com/repos/awawa-dev/HyperHDR" | jq -r '.description')"
printf "%s" "${DESCRIPTION}"
