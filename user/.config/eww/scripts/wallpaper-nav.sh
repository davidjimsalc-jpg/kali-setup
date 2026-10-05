#!/bin/bash

STATE="$HOME/.cache/eww-wallpaper-index"
WALLDIR="$HOME/Conf_desktop/Wallpapers"

mapfile -d '' WALLS < <(
    find "$WALLDIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 | sort -z
)

COUNT=${#WALLS[@]}
[ "$COUNT" -eq 0 ] && exit 1

if [ -f "$STATE" ]; then
    SELECTED="$(cat "$STATE")"
else
    SELECTED=0
fi

cleanup_picker() {
    eww close-all 2>/dev/null
    sleep 0.05
    eww kill 2>/dev/null

    pkill -x sxhkd
    sxhkd -c "$HOME/.config/sxhkd/sxhkdrc" >/dev/null 2>&1 &
    disown
}

update_carousel() {
    local index="$1"
    local content

    echo "$index" > "$STATE"

    content="$("$HOME/.config/eww/scripts/wallpapers.sh" "$index")"

    eww update selected="$index"
    eww update "wallpapers=$content"
}

case "$1" in

    left)
        if [ "$SELECTED" -gt 0 ]; then
            SELECTED=$((SELECTED - 1))
            update_carousel "$SELECTED"
        fi
        ;;

    right)
        if [ "$SELECTED" -lt $((COUNT - 1)) ]; then
            SELECTED=$((SELECTED + 1))
            update_carousel "$SELECTED"
        fi
        ;;

    select)
    WALL="${WALLS[$SELECTED]}"

    cleanup_picker

    set-wallpaper "$WALL"
    ;;

close)
    cleanup_picker
    ;;

esac
