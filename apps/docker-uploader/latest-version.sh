#!/usr/bin/env bash

version=$(curl -sX GET https://api.github.com/repos/linuxserver/docker-baseimage-alpine/releases/latest | jq --raw-output '. | .tag_name')
printf "%s" "${version}"
