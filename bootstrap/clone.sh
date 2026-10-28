#!/bin/sh

echo "Cloning repositories..."
CODE=$HOME/Developer
USERNAME=GiorgioMendieta

# Example: git clone git@github.com:GiorgioMendieta/${REPO}.git $CODE/

REPOS="obsidian-vault homelab"
for REPO in $REPOS; do
    git clone git@github.com:${USERNAME}/${REPO}.git $CODE/
done