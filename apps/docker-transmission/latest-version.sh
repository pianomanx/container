#!/usr/bin/env bash

version=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp && awk '/^P:transmission-daemon$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
