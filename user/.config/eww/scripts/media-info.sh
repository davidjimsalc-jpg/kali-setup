#!/bin/bash

PLAYER="spotify"
COVER="$HOME/.cache/spotify-cover.jpg"

if ! playerctl -l 2>/dev/null | grep -qx "$PLAYER"; then
    echo '{"playing":false}'
    exit 0
fi

TITLE="$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)"
ARTIST="$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null)"
STATUS="$(playerctl -p "$PLAYER" status 2>/dev/null)"
ARTURL="$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null)"
POSITION="$(playerctl -p "$PLAYER" position 2>/dev/null)"
LENGTH="$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)"

[ -z "$POSITION" ] && POSITION=0
[ -z "$LENGTH" ] && LENGTH=0

LENGTH_SEC=$((LENGTH / 1000000))

if [ "$LENGTH_SEC" -gt 0 ]; then
    PROGRESS=$(awk -v p="$POSITION" -v l="$LENGTH_SEC" \
        'BEGIN { printf "%.0f", (p/l)*100 }')
else
    PROGRESS=0
fi

format_time() {
    local value="${1%.*}"
    printf "%02d:%02d" $((value / 60)) $((value % 60))
}

POS_TIME="$(format_time "$POSITION")"
LEN_TIME="$(format_time "$LENGTH_SEC")"

if [ -n "$ARTURL" ]; then
    curl -Ls "$ARTURL" -o "$COVER.tmp" 2>/dev/null &&
    mv "$COVER.tmp" "$COVER"
fi

TITLE="${TITLE//\"/\\\"}"
ARTIST="${ARTIST//\"/\\\"}"

printf '{"playing":true,"title":"%s","artist":"%s","status":"%s","progress":%s,"position":"%s","length":"%s","cover":"%s"}\n' \
    "$TITLE" \
    "$ARTIST" \
    "$STATUS" \
    "$PROGRESS" \
    "$POS_TIME" \
    "$LEN_TIME" \
    "$COVER"
