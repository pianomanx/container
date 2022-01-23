#!/usr/bin/env bash
version="$(curl -sX GET https://repo.jellyfin.org/ubuntu/dists/focal/main/binary-amd64/Packages | grep -A 8 -m 1 'Package: jellyfin-server' | awk -F ': ' '/Version/{print $2;exit}')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
