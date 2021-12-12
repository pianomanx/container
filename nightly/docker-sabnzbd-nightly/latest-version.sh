#!/usr/bin/env bash

version="$( curl -s https://api.github.com/repos/sabnzbd/sabnzbd/releases | jq -r 'first(.[]) | .tag_name')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
