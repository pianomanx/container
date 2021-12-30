#!/usr/bin/env bash
version="$(curl -u $username:$token -X GET "https://api.github.com/repos/mregni/EmbyStat/releases" | jq -r 'first(.[] | .tag_name)')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"

