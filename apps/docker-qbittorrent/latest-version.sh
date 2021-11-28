#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/qbittorrent/qBittorrent/tags" | jq --raw-output 'map(select(.name | test("^release-[0-9]+.[0-9]+.[0-9]+$"))) | first.name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
