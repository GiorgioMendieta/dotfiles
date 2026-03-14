#!/bin/bash

set -euo pipefail

[ -f "${DOTFILES}/Apps/immich/env" ] && source "${DOTFILES}/Apps/immich/env"

_immich_scan() {
    # Use Immich API 
    curl -L -X POST "https://immich.home.arpa/api/libraries/${IMMICH_LIBRARY_ID}/scan" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -H "x-api-key: ${IMMICH_API_KEY}"
}

immich() {
    local SRC_DIR="${HOME}/Desktop/tmp"
    local DST_DIR="$1"

    if [ -z "${DST_DIR}" ]; then
        echo "Usage: immich YYYY/MM"
        return 1
    fi

    # Delete .DS_Store files beforehand
    find ${SRC_DIR} -name ".DS_Store" -type f -delete

    rsync -chavzP --stats --mkpath \
        "${SRC_DIR}/" \
        "pve:/mnt/pve/myhdd/photos/${DST_DIR}/"

    ssh pve immich
    echo "Permissions set for photos directory"

    _immich_scan
    echo "Scanning library for changes"
    # Open with Safari
    open "https://immich.home.arpa/admin/queues"
}

# Call function and pass arguments
immich "$@"
