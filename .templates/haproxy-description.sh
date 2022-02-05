#!/usr/bin/env bash
version=$(curl -sX GET "https://registry.hub.docker.com/v1/repositories/library/haproxy/tags" | jq --raw-output '.[] | select(.name | contains(".")) | .name' | grep -vE '*dev*' | grep -vE '*bullsey*'  | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
#version="${version#*v}"
#version="${version#*release-}"
printf "%s" "${version}"
