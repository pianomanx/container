#!/usr/bin/env bash
version=$(curl -u $username:$token -sX  GET "https://api.github.com/repos/sct/overseerr/commits?sha=develop" | jq -r 'first(.[] | select(.commit.message | contains("[skip ci]") | not)) | .sha')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
