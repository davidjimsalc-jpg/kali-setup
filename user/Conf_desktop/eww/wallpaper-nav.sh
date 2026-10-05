#!/bin/bash

WALLDIR="$HOME/Conf_desktop/Wallpapers"

mapfile -d '' WALLS < <(
    find "$WALLDIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 | sort -z
)

COUNT=${#WALLS[@]}
[ "$COUNT" -eq 0 ] && exit 1

CURRENT=$(eww get selected 2>/dev/null)
CURRENT=${CURRENT:-0}

restore_sxhkd() {
    pkill -x sxhkd
    sxhkd -c "$HOME/.config/sxhkd/sxhkdrc" &
}

case "$1" in

    left)
        NEW=$((CURRENT - 1))

        if [ "$NEW" -lt 0 ]; then
            NEW=$((COUNT - 1))
        fi

        eww update selected="$NEW"
        ;;

    right)
        NEW=$((CURRENT + 1))

        if [ "$NEW" -ge "$COUNT" ]; then
            NEW=0
        fi

        eww update selected="$NEW"
        ;;

    select)
        WALL="${WALLS[$CURRENT]}"

        eww close wallpaper-picker
        set-wallpaper "$WALL"

        restore_sxhkd
        ;;

    close)
        eww close wallpaper-picker
        restore_sxhkd
        ;;
esac
