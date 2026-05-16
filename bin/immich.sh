#!/bin/bash

set -euo pipefail

# Ensure the dotfiles root is available before loading environment variables.
if [ -z "${DOTFILES:-}" ]; then
    echo "-> [Error] DOTFILES is not set."
    exit 1
fi

# Get immich api key from env variable file
[ -f "${DOTFILES}/Apps/immich/env" ] && source "${DOTFILES}/Apps/immich/env"

_immich_scan_library() {
    echo "-> [Info] Triggering Immich library scan..."

    # Sends a POST request to trigger library scan using Immich API /send endpoint
    # Fail and show error in case of problem
    curl -fsSL -X POST "https://immich.home.arpa/api/libraries/${IMMICH_LIBRARY_ID}/scan" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -H "x-api-key: ${IMMICH_API_KEY}"
}

_organize_files() {
    local SRC_DIR="$1"

    echo "-> [Info] Organizing files with exiftool..."
    # Organize files into YYYY/MM directory structure based on CreateDate
    exiftool \
        '-filename<CreateDate' \
        -d "$SRC_DIR"/%Y/%m/%Y%m%d_%H%M%S%%-c.%%e \
        -m "$SRC_DIR"
}

_send_to_immich() {
    local SRC_DIR="$1"
    local DST_DIR="/mnt/pve/myhdd/photos"

    echo "-> [Info] Sending files to NAS with rsync..."
    # --exclude: ignores Apple/Windows metadata
    # --mkpath: ensures remote dir exists
    rsync -chavzP --stats \
        --exclude '.DS_Store' \
        --exclude '._*' \
        --exclude 'Thumbs.db' \
        --remove-source-files \
        --mkpath \
        "${SRC_DIR}/" \
        "pve:${DST_DIR}/"
}

_cleanup_empty_dirs() {
    local SRC_DIR="$1"

    echo "-> [Info] Removing empty folders from source directory..."
    # Delete only empty subdirectories and keep SRC_DIR itself.
    find "$SRC_DIR" -depth -mindepth 1 -type d -empty -delete
}

immich() {
    # Define source and destination directories
    local SRC_DIR="${HOME}/Desktop/send_to_immich"

    # 1. Sanity Check: Does the source directory actually exist?
    if [ ! -d "$SRC_DIR" ]; then
        echo "-> [Error] Local directory $SRC_DIR does not exist."
        return 1
    fi

    # Organize files into YYYY/MM structure 
    _organize_files "$SRC_DIR"

    # Send files to NAS and remove source files after successful transfer
    _send_to_immich "$SRC_DIR"

    # Remove empty YYYY/MM directories left after moving files
    _cleanup_empty_dirs "$SRC_DIR"

    # Set correct permissions for remote directory
    ssh pve set_photo_permissions
    echo "-> [Info] Permissions set for photos directory in NAS"

    # Trigger immich library scan
    _immich_scan_library

    # Optional: Only open Safari if in a GUI session
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://immich.home.arpa/admin/queues"
    fi

    echo "-> [Success] Done"
    return 0
}

# Call function and pass arguments
immich "$@"
