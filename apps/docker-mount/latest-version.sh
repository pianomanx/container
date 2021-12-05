#!/usr/bin/env bash
version=$(curl -s "https://registry.hub.docker.com/v1/repositories/library/alpine/tags" | jq --raw-output '.[] | select(.name | contains(".")) | .name' | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
printf "%s" "${version}"
