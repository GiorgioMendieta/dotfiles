#!/bin/bash

set -euo pipefail

# Ensure the dotfiles root is available before loading environment variables.
if [ -z "${DOTFILES:-}" ]; then
    echo "-> [ERROR] DOTFILES is not set."
    exit 1
fi

# Get immich api key from env variable file
[ -f "${DOTFILES}/Apps/immich/env" ] && source "${DOTFILES}/Apps/immich/env"

_immich_scan_library() {
    echo "-> [INFO] Triggering Immich library scan..."

    # Sends a POST request to trigger library scan using Immich API /send endpoint
    # Fail and show error in case of problem
    curl -fsSL -X POST "https://immich.home.arpa/api/libraries/${IMMICH_LIBRARY_ID}/scan" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -H "x-api-key: ${IMMICH_API_KEY}"
}

_organize_files() {
    local SRC_DIR="$1"

    echo "-> [INFO] Organizing files with exiftool..."
    # Organize files into YYYY/MM directory structure based on CreateDate
    # while keeping original filenames unchanged.
    exiftool \
        '-Directory<CreateDate' \
        -d "$SRC_DIR"/%Y/%m \
        -m "$SRC_DIR"
}

_send_to_immich() {
    local SRC_DIR="$1"
    local BASE_DIR="/mnt/pve/myhdd/photos"
    local CUSTOM_DST="${2:-}"

    # Strip any leading slash from custom destination to avoid double slashes
    CUSTOM_DST="${CUSTOM_DST#/}"

    local DST_DIR

    if [ -n "$CUSTOM_DST" ]; then
        DST_DIR="${BASE_DIR}/${CUSTOM_DST}"
    else
        DST_DIR="${BASE_DIR}"
    fi

    echo "-> [INFO] Sending files to NAS with rsync..."
    echo "-> [INFO] Destination: pve:${DST_DIR}"

    # rsync options explained:
    # -c: checksum to ensure file integrity
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -h: human-readable output
    # -z: compress file data during transfer
    # -P: show progress and keep partially transferred files
    # --exclude: ignores Apple/Windows metadata
    # --mkpath: ensures remote dir exists

    rsync -chazP \
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

    echo "-> [INFO] Removing empty folders from source directory..."
    # Delete only empty subdirectories and keep SRC_DIR itself.
    find "$SRC_DIR" -depth -mindepth 1 -type d -empty -delete
}

immich() {
    # Define source and destination directories
    local SRC_DIR="${HOME}/Desktop/send_to_immich"
    local CUSTOM_DST="${1:-}"

    # 1. Sanity Check: Does the source directory actually exist?
    if [ ! -d "$SRC_DIR" ]; then
        echo "-> [ERROR] Local directory $SRC_DIR does not exist."
        return 1
    fi

    # Organize only if no custom destination was provided
    if [ -z "$CUSTOM_DST" ]; then
        # Organize files into YYYY/MM structure
        _organize_files "$SRC_DIR"
    else
        echo "-> [INFO] Custom destination specified, skipping exiftool organization"
    fi

    # Send files to NAS and remove source files after successful transfer
    _send_to_immich "$SRC_DIR" "$CUSTOM_DST"

    # Remove empty YYYY/MM directories left after moving files
    _cleanup_empty_dirs "$SRC_DIR"

    # Set correct permissions for remote directory
    ssh pve set_photo_permissions
    echo "-> [INFO] Permissions set for photos directory in NAS"

    # Trigger immich library scan
    _immich_scan_library

    # Optional: Only open Safari if in a GUI session
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://immich.home.arpa/admin/queues"
    fi

    echo "-> [SUCCESS] Done"
    return 0
}

# If script is executed directly, call the immich function with first arg
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    immich "${1:-}"
fi
