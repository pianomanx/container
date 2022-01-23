#!/usr/bin/env bash
version=$(curl -s "https://registry.hub.docker.com/v1/repositories/library/haproxy/tags" | jq --raw-output '.[] | select(.name | contains(".")) | .name' | grep -vE "*dev*|*bullsey*" | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1)
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
