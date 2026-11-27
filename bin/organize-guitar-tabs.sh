#!/usr/bin/env bash

set -euo pipefail

# Organize files in the specified directory into subdirectories based on the first character of their names.

# Keep [a-zA-Z] ranges strictly ASCII regardless of the user's locale.
export LC_COLLATE=C

DRY_RUN=false
ROOT="."

# Directories to exclude (directory names, not paths).
EXCLUDED_DIRS=(
    "Tabbed"
    "Original"
    "TODO"
)

usage() {
    echo "Usage: $0 [--dry-run] [DIRECTORY]"
    exit 1
}

is_excluded() {
    local name="$1" dir
    for dir in "${EXCLUDED_DIRS[@]}"; do
        [[ "$dir" == "$name" ]] && return 0
    done
    return 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ "$ROOT" != "." ]]; then
                usage
            fi
            ROOT="$1"
            shift
            ;;
    esac
done

if [[ ! -d "$ROOT" ]]; then
    echo "Error: '$ROOT' is not a directory" >&2
    exit 1
fi

# Resolve to an absolute, symlink-free path
ROOT="$(cd -- "$ROOT" && pwd -P)"

if $DRY_RUN; then
    echo "Dry-run mode: no changes will be made."
fi

# Unmatched globs expand to nothing instead of the literal pattern
shopt -s nullglob

# Create buckets for letters A-Z and numbers 0-9.
for file in "$ROOT"/[!.]*; do
    # Regular files only, following symlinks (zsh's -.).
    [[ -f "$file" ]] || continue

    # Skip files inside excluded directories.
    parent="${file%/*}"

    while [[ "$parent" != "$ROOT" ]]; do
        if is_excluded "${parent##*/}"; then
            continue 2
        fi

        parent="${parent%/*}"
    done

    filename="${file##*/}"
    first_char="${filename:0:1}"

    # Determine destination bucket.
    if [[ "$first_char" == [0-9] ]]; then
        bucket="0-9"
    elif [[ "$first_char" == [a-zA-Z] ]]; then
        # Uppercase the first character for bucket naming (works on bash 3.2+).
        bucket="$(printf '%s' "$first_char" | tr '[:lower:]' '[:upper:]')"
    else
        continue
    fi

    # Skip files already in their correct bucket.
    if [[ "${file%/*}" == "$ROOT/$bucket" ]]; then
        continue
    fi

    destination="$ROOT/$bucket/$filename"

    # Avoid overwriting existing files.
    if [[ -e "$destination" ]]; then
        echo "SKIP (destination exists): $file -> $destination"
        continue
    fi

    relative_file="./${file#"$ROOT"/}"
    relative_destination="./$bucket/$filename"

    if $DRY_RUN; then
        echo "MOVE: $relative_file -> $relative_destination"
    else
        mkdir -p "$ROOT/$bucket"
        mv -- "$file" "$destination"
        echo "MOVED: $relative_file -> $relative_destination"
    fi
done

printf '\nDone!\n'

