#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/zSeriesGuy/Tautulli/releases/latest" | jq --raw-output '. | .tag_name')
version="${version#*V}"
version="${version#*release-}"
printf "%s" "${version}"
