#!/bin/bash

set -euo pipefail

# Get immich api key from env variable file
[ -f "${DOTFILES}/Apps/immich/env" ] && source "${DOTFILES}/Apps/immich/env"

_immich_scan_library() {
    echo "Scanning Immich library..."

    # Sends a POST request to trigger library scan using Immich API /send endpoint
    # Fail and show error in case of problem
    curl -fsSL -X POST "https://immich.home.arpa/api/libraries/${IMMICH_LIBRARY_ID}/scan" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -H "x-api-key: ${IMMICH_API_KEY}"
}

immich() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: immich YYYY/MM"
        return 1
    fi

    local SRC_DIR="${HOME}/Desktop/send_to_immich"
    local DST_DIR="$1"
    local REMOTE_DIR="/mnt/pve/myhdd/photos/${DST_DIR}"

    # 1. Sanity Check: Does the source directory actually exist?
    if [ ! -d "$SRC_DIR" ]; then
        echo "Error: Local directory $SRC_DIR does not exist."
        return 1
    fi

    echo "Syncing $DST_DIR to NAS..."

    # --exclude: ignores Apple/Windows metadata
    # --mkpath: ensures remote dir exists
    rsync -chavzP --stats \
        --exclude '.DS_Store' \
        --exclude '._*' \
        --exclude 'Thumbs.db' \
        --remove-source-files \
        --ignore-existing \
        --mkpath \
        "${SRC_DIR}/" \
        "pve:${REMOTE_DIR}"

    # Set correct permissions for remote directory
    ssh pve set_photo_permissions
    echo "✅ Permissions set for photos directory"

    # Trigger immich library scan
    _immich_scan_library

    # Optional: Only open Safari if in a GUI session
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://immich.home.arpa/admin/queues"
    fi
}

# Call function and pass arguments
immich "$@"
