#!/usr/bin/env bash
set -uo pipefail

dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" |
while read -r line; do
    if [[ $line == *"boolean false"* ]]; then
        sleep 2
        "$HOME/.config/hypr/lid-setup.sh"
        sleep 5
        "$HOME/.config/hypr/lid-setup.sh"
    fi
done
