#!/bin/bash

WALLDIR="$HOME/Conf_desktop/Wallpapers"
THUMBDIR="$HOME/.cache/eww-wallpapers"

SELECTED="${1:-0}"

mkdir -p "$THUMBDIR"

mapfile -d '' WALLS < <(
    find "$WALLDIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -print0 | sort -z
)

COUNT=${#WALLS[@]}

[ "$COUNT" -eq 0 ] && {
    echo '(box)'
    exit
}

# Limitar índice
[ "$SELECTED" -lt 0 ] && SELECTED=0
[ "$SELECTED" -ge "$COUNT" ] && SELECTED=$((COUNT - 1))


make_thumb_center() {
    local wall="$1"
    local name thumb

    name="$(basename "$wall")"
    thumb="$THUMBDIR/${name%.*}-center.png"

    if [ ! -f "$thumb" ] || [ "$wall" -nt "$thumb" ]; then
        convert "$wall" \
            -resize '520x340^' \
            -gravity center \
            -extent 520x340 \
            -background none \
            -alpha set \
            \( -size 520x340 xc:none \
               -fill white \
               -draw "roundrectangle 1,1 518,338 18,18" \
            \) \
            -compose CopyOpacity \
            -composite \
            PNG32:"$thumb"
    fi

    printf '%s' "$thumb"
}


make_thumb_side() {
    local wall="$1"
    local name thumb

    name="$(basename "$wall")"
    thumb="$THUMBDIR/${name%.*}-side.png"

    if [ ! -f "$thumb" ] || [ "$wall" -nt "$thumb" ]; then
        convert "$wall" \
            -resize '260x340^' \
            -gravity center \
            -extent 260x340 \
            -background none \
            -alpha set \
            \( -size 260x340 xc:none \
               -fill white \
               -draw "roundrectangle 1,1 258,338 16,16" \
            \) \
            -compose CopyOpacity \
            -composite \
            PNG32:"$thumb"
    fi

    printf '%s' "$thumb"
}


make_item() {
    local idx="$1"
    local size="$2"
    local role="$3"

    local original="${WALLS[$idx]}"
    local path

    if [ "$role" = "center" ]; then
        path="$(make_thumb_center "$original")"
    else
        path="$(make_thumb_side "$original")"
    fi

    printf '
(eventbox
  :cursor "pointer"
  :onhover "~/.config/eww/scripts/wallpaper-nav.sh goto %s"
  :onclick "~/.config/eww/scripts/wallpaper-nav.sh goto %s"

  (box
    :class "wall-item %s"

    (image
      :class "wallpaper %s"
      :path "%s"
      :image-width %s
      :image-height %s
      :preserve-aspect-ratio true
    )
  )
)
' \
    "$idx" "$idx" "$role" "$role" "$path" "$size" "$size"
}


LEFT=""
CENTER=""
RIGHT=""

LEFT='(box :class "wall-side left" :width 0 :orientation "horizontal" :halign "end" :spacing 0 '

if [ $((SELECTED-2)) -ge 0 ]; then
    LEFT+="$(make_item $((SELECTED-2)) 210 far-left)"
fi

if [ $((SELECTED-1)) -ge 0 ]; then
    LEFT+="$(make_item $((SELECTED-1)) 310 near-left)"
fi

LEFT+=')'


CENTER="$(make_item "$SELECTED" 600 center)"


RIGHT='(box :class "wall-side right" :width 0 :orientation "horizontal" :halign "start" :spacing 0 '

if [ $((SELECTED+1)) -lt "$COUNT" ]; then
    RIGHT+="$(make_item $((SELECTED+1)) 310 near-right)"
fi

if [ $((SELECTED+2)) -lt "$COUNT" ]; then
    RIGHT+="$(make_item $((SELECTED+2)) 210 far-right)"
fi

RIGHT+=')'


LEFT_ARROW='(label :class "nav-arrow left-arrow" :text "")'
RIGHT_ARROW='(label :class "nav-arrow right-arrow" :text "")'


#
# CARRUSEL
#
printf '
(centerbox
  :class "carousel-shell"
  :orientation "horizontal"

  (box
    :class "arrow-slot left-slot"
    :halign "center"
    :valign "center"
    %s
  )

  (centerbox
    :class "wall-carousel"
    :orientation "horizontal"

    %s
    %s
    %s
  )

  (box
    :class "arrow-slot right-slot"
    :halign "center"
    :valign "center"
    %s
  )
)
' "$LEFT_ARROW" "$LEFT" "$CENTER" "$RIGHT" "$RIGHT_ARROW"
