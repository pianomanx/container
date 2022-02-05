#!/usr/bin/env bash

version=$(curl -s "https://registry.hub.docker.com/v1/repositories/eafxx/alpine-python/tags" | jq --raw-output '.[] | select(.name | contains("latest")) | .name' | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
printf "%s" "${version}"
