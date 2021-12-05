#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_^v__')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
