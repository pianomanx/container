#!/usr/bin/env bash

version="$(curl -sX GET "https://api.github.com/repos/duplicati/duplicati/releases" | jq -r '. | first(.[] | select(.tag_name)) | .tag_name' | sed -r 's/.{28}$//')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
