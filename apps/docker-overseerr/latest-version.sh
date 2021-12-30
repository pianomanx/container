#!/usr/bin/env bash
version="$(curl -u $username:$token -X GET "https://api.github.com/repos/sct/overseerr/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
