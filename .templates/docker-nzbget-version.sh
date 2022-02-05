#!/usr/bin/env bash
 
version="$(curl -u $username:$token -sX GET "https://api.github.com/repos/nzbget/nzbget/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
