#!/usr/bin/env bash

version="$(curl -fsSL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp && \
       awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
