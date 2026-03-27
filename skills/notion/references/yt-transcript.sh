#!/bin/bash
# Extract YouTube transcript as plain text
# Usage: yt-transcript.sh <youtube_url>
# Tries Supadata API first, falls back to yt-dlp
URL="$1"
SUPADATA_KEY="${SUPADATA_API_KEY:-sd_59164ae9bcd2e54e9564c0cf53f12aa8}"
ENCODED_URL=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$URL', safe=''))")

# Method 1: Supadata API (via curl)
RESULT=$(curl -s "https://api.supadata.ai/v1/youtube/transcript?url=$ENCODED_URL" \
  -H "x-api-key: $SUPADATA_KEY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    items = []
    if isinstance(data, dict) and 'content' in data:
        items = data['content'] if isinstance(data['content'], list) else []
    elif isinstance(data, list):
        items = data
    if items:
        for item in items:
            text = item.get('text', '')
            offset = item.get('offset', 0)
            mins = int(offset / 1000 / 60)
            secs = int((offset / 1000) % 60)
            print(f'[{mins:02d}:{secs:02d}] {text}')
    else:
        print('SUPADATA_EMPTY')
except:
    print('SUPADATA_FAIL')
" 2>/dev/null)

if echo "$RESULT" | grep -q "SUPADATA_FAIL\|SUPADATA_EMPTY"; then
    # Method 2: yt-dlp fallback
    TMPDIR=$(mktemp -d)
    export PATH="$PATH:/root/.deno/bin"
    yt-dlp --write-auto-sub --sub-lang en --skip-download --sub-format vtt -o "$TMPDIR/sub" "$URL" >/dev/null 2>&1
    if [ -f "$TMPDIR/sub.en.vtt" ]; then
        grep -v "^$\|^WEBVTT\|^Kind:\|^Language:\|-->\\|^[0-9]" "$TMPDIR/sub.en.vtt" | \
        awk '!seen[$0]++' | \
        sed 's/<[^>]*>//g' | \
        tr '\n' ' ' | \
        sed 's/  */ /g'
    else
        echo "No transcript available from any source"
    fi
    rm -rf "$TMPDIR"
else
    echo "$RESULT"
fi
