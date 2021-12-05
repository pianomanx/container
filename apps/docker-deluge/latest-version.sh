#!/usr/bin/env bash

version="$(curl -sX GET http://ppa.launchpad.net/deluge-team/stable/ubuntu/dists/focal/main/binary-amd64/Packages.gz | \
   gunzip -c |grep -A 7 -m 1 '^Package: deluged$' | \
   awk -F ': ' '/Version/{print $2;exit}' | sed -r 's/.{27}$//')"

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
