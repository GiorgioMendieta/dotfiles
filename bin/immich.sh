#!/bin/bash

set -euo pipefail

if [[ -t 1 ]]; then
    readonly COLOR_RESET=$'\033[0m'
    readonly COLOR_INFO=$'\033[36m'
    readonly COLOR_WARN=$'\033[33m'
    readonly COLOR_ERROR=$'\033[31m'
    readonly COLOR_OK=$'\033[32m'
else
    readonly COLOR_RESET=''
    readonly COLOR_INFO=''
    readonly COLOR_WARN=''
    readonly COLOR_ERROR=''
    readonly COLOR_OK=''
fi

_log() {
    local level="$1"
    local message="$2"
    local color

    case "$level" in
        INFO) color="$COLOR_INFO" ;;
        WARN) color="$COLOR_WARN" ;;
        ERROR) color="$COLOR_ERROR" ;;
        OK) color="$COLOR_OK" ;;
        *) color="$COLOR_RESET" ;;
    esac

    printf '%s[ %s ]%s %s\n' "$color" "$level" "$COLOR_RESET" "$message"
}

# Ensure the dotfiles root is available before loading environment variables.
if [ -z "${DOTFILES:-}" ]; then
    _log ERROR "DOTFILES is not set."
    exit 1
fi

# Get immich api key from env variable file
[ -f "${DOTFILES}/Apps/immich/env" ] && source "${DOTFILES}/Apps/immich/env"

_immich_scan_library() {
    _log INFO "Triggering Immich library scan..."

    # Sends a POST request to trigger library scan using Immich API /send endpoint
    # Fail and show error in case of problem
    curl -fsSL -X POST "https://immich.giorgiomendieta.com/api/libraries/${IMMICH_LIBRARY_ID}/scan" \
	    -H "Content-Type: application/json" \
	    -H "Accept: application/json" \
	    -H "x-api-key: ${IMMICH_API_KEY}"
}

_organize_files() {
    local SRC_DIR="$1"

    _log INFO "Organizing files with exiftool..."
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

    _log INFO "Sending files to NAS with rsync..."
    _log INFO "Destination: pve:${DST_DIR}"

    # rsync options explained:
    # -c: checksum to ensure file integrity
    # -a: archive mode (preserves permissions, timestamps, etc.)
    # -h: human-readable output
    # -z: compress file data during transfer
    # -P: show progress and keep partially transferred files (deprecated)
    # --partial: resumable transfers
    # --info=progress2: overall progress bar
    #   PROGRESS   Mention 1) per-file progress or 2) total transfer progress
    # --stats: summary at the end
    # --exclude: ignores Apple/Windows metadata
    # --mkpath: ensures remote dir exists

    /opt/homebrew/bin/rsync -chaz \
        --partial \
        --info=progress2 \
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

    _log INFO "Removing empty folders from source directory..."
    # Delete only empty subdirectories and keep SRC_DIR itself.
    find "$SRC_DIR" -depth -type d -empty -delete
}

_usage() {
        cat <<'EOF'
Usage:
    immich.sh [DESTINATION]

Options:
    -h, --help   Show this help text and exit
    --scan       Trigger external library scan

Arguments:
    DESTINATION  Optional subdirectory under /mnt/pve/myhdd/photos

Examples:
    immich.sh
    immich.sh events/2026
EOF
}

immich() {
    # Define source and destination directories
    local SRC_DIR="${HOME}/Desktop/send_to_immich"
    local CUSTOM_DST="${1:-}"

        case "$CUSTOM_DST" in
                -h|--help)
                        _usage
                        return 0
                        ;;
                --scan)
                        _immich_scan_library
                        return 0
                        ;;
        esac

    # 1. Sanity Check: Does the source directory actually exist?
    if [ ! -d "$SRC_DIR" ]; then
        _log ERROR "Local directory $SRC_DIR does not exist."
        return 1
    fi

    # Organize only if no custom destination was provided
    if [ -z "$CUSTOM_DST" ]; then
        # Organize files into YYYY/MM structure
        _organize_files "$SRC_DIR"
    else
        _log INFO "Custom destination specified, skipping exiftool organization"
    fi

    # Send files to NAS and remove source files after successful transfer
    _send_to_immich "$SRC_DIR" "$CUSTOM_DST"

    # Remove empty YYYY/MM directories left after moving files
    _cleanup_empty_dirs "$SRC_DIR"

    # Set correct permissions for remote directory
    ssh pve set_photo_permissions
    _log INFO "Permissions set for photos directory in NAS"

    # Trigger immich library scan
    _immich_scan_library

    # Optional: Only open Safari if in a GUI session
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://immich.giorgiomendieta.com/admin/queues"
    fi

    _log OK "Done"
    return 0
}

# If script is executed directly, call the immich function with first arg
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        -h|--help)
            _usage
            exit 0
            ;;
    esac

    immich "${1:-}"
fi
