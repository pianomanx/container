#!/usr/bin/env bash
version="$(curl -u $username:$token -sX GET "https://api.github.com/repos/sabnzbd/sabnzbd/commits/develop" | jq -r .sha)"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
