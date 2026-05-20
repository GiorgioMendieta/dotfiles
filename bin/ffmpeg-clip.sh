#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <video_file> <HH:MM:SS> [padding_seconds]"
    echo
    echo "Example:"
    echo "  $0 video.mp4 01:13:20"
    echo "  $0 video.mp4 01:13:20 90"
    exit 1
fi

INPUT="$1"
TIMESTAMP="$2"
PADDING="${3:-60}"

BASENAME="$(basename "$INPUT")"
EXTENSION="${BASENAME##*.}"
FILENAME="${BASENAME%.*}"

# Convert HH:MM:SS -> seconds
to_seconds() {
    IFS=: read -r h m s <<< "$1"
    echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

# Convert seconds -> HH:MM:SS
to_hms() {
    local total=$1

    local h=$((total / 3600))
    local m=$(((total % 3600) / 60))
    local s=$((total % 60))

    printf "%02d:%02d:%02d" "$h" "$m" "$s"
}

TARGET_SECONDS="$(to_seconds "$TIMESTAMP")"

START_SECONDS=$((TARGET_SECONDS - PADDING))
if (( START_SECONDS < 0 )); then
    START_SECONDS=0
fi

DURATION_SECONDS=$((PADDING * 2))

START_HMS="$(to_hms "$START_SECONDS")"
DURATION_HMS="$(to_hms "$DURATION_SECONDS")"

OUTPUT="${FILENAME}_clip.${EXTENSION}"

echo "Input     : $INPUT"
echo "Timestamp : $TIMESTAMP"
echo "Padding   : ${PADDING}s"
echo "Start     : $START_HMS"
echo "Duration  : $DURATION_HMS"
echo "Output    : $OUTPUT"

ffmpeg \
    -loglevel error \
    -ss "$START_HMS" \
    -i "$INPUT" \
    -t "$DURATION_HMS" \
    -c copy \
    "$OUTPUT"