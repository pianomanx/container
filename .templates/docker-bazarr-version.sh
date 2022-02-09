#!/usr/bin/env bash

version="$(curl -u $username:$token -sX GET "https://api.github.com/repos/morpheus65535/bazarr/releases/latest" | jq --raw-output '.tag_name')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
