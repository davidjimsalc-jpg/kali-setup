#!/bin/bash

wid=$(bspc query -N -n focused)
pid=$(xprop -id "$wid" _NET_WM_PID 2>/dev/null | awk '{print $3}')

kill_tree() {
    local parent=$1

    for child in $(pgrep -P "$parent"); do
        kill_tree "$child"
    done

    if [[ "$parent" != "$pid" ]]; then
        kill -TERM "$parent" 2>/dev/null
    fi
}

if [[ -n "$pid" && "$pid" =~ ^[0-9]+$ ]]; then
    kill_tree "$pid"
fi

bspc node "$wid" -k
