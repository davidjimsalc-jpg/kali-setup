#!/bin/sh

ip=$(ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)

[ -n "$ip" ] && echo "VPN $ip"
