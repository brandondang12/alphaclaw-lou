#!/bin/bash
# Extract YouTube transcript as plain text
# Usage: yt-transcript.sh <youtube_url>
URL="$1"
TMPDIR=$(mktemp -d)
yt-dlp --write-auto-sub --sub-lang en --skip-download --sub-format vtt -o "$TMPDIR/sub" "$URL" >/dev/null 2>&1
# Convert VTT to plain text (remove timestamps and duplicates)
if [ -f "$TMPDIR/sub.en.vtt" ]; then
    grep -v "^$\|^WEBVTT\|^Kind:\|^Language:\|-->\\|^[0-9]" "$TMPDIR/sub.en.vtt" | \
    awk '!seen[$0]++' | \
    sed 's/<[^>]*>//g' | \
    tr '\n' ' ' | \
    sed 's/  */ /g'
else
    echo "No transcript available"
fi
rm -rf "$TMPDIR"
