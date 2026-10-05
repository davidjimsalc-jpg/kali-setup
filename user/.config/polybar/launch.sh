#!/usr/bin/env sh

killall -q polybar

while pgrep -u "$(id -u)" -x polybar >/dev/null; do
    sleep 1
done

polybar left -c ~/.config/polybar/current.ini &
polybar center -c ~/.config/polybar/current.ini &
polybar right -c ~/.config/polybar/current.ini &
