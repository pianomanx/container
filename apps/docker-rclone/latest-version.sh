#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/rclone/rclone/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | sed -e 's_^v__')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
