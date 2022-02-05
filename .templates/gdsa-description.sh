#!/usr/bin/env bash

version="$(curl -s "https://registry.hub.docker.com/v1/repositories/google/cloud-sdk/tags" \
     | jq --raw-output '.[] | select(.name | contains(".")) | .name' \
     | sort -t "." -k1,1n -k2,2n -k3,3n \
     | sed -r 's/[-].*$//' | tail -n 1)"
printf "%s" "${version}"
