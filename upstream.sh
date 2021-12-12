#!/bin/bash

cd /media/container
if [[ -n $(git status --porcelain) ]]; then
   git config --global user.name 'github-actions[bot]' 
   git config --global user.email 'github-actions[bot]@users.noreply.github.com' 
   git add -A
   git commit -sam "[UPSTREAM] Adding new features" || exit 0
   git push
fi
