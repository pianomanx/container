#!/usr/bin/env bash
version="$(curl -u $username:$token -X GET "https://api.github.com/repos/linuxserver/docker-baseimage-alpine/releases/latest" | jq --raw-output '. | .tag_name')"
version="${version#*V}"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
