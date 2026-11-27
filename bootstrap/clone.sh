#!/usr/bin/env bash
set -Eeuo pipefail

echo "Cloning repositories..."
CODE="$HOME/Developer"
USERNAME="GiorgioMendieta"
REPOS=(obsidian-vault homelab dusklight)

mkdir -p "$CODE"

for REPO in "${REPOS[@]}"; do
    destination="$CODE/$REPO"
    if [[ -e "$destination/.git" ]]; then
        printf 'Repository already exists, skipping: %s\n' "$destination"
        continue
    fi
    if [[ -e "$destination" ]]; then
        printf 'Repository destination exists but is not a Git checkout: %s\n' "$destination" >&2
        exit 1
    fi
    git clone "git@github.com:${USERNAME}/${REPO}.git" "$destination"
done
