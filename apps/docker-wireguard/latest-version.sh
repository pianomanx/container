#!/usr/bin/env bash
version="$(curl -u $username:$token -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" | jq --raw-output '.[0].name')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
