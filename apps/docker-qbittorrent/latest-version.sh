#!/usr/bin/env bash

version="$(curl -sX GET http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/focal/main/binary-amd64/Packages.gz | \
    gunzip -c |grep -A 7 -m 1 'Package: qbittorrent-nox' | awk -F ': ' '/Version/{print $2;exit}' | sed -e 's/1://g' | sed -r 's/.{42}$//')"

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
