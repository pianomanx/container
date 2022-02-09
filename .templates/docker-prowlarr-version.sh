#!/usr/bin/env bash
PROWLARR_BRANCH="nightly"
version=$(curl -fsSL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" | jq -r '.[0].version')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
