#!/usr/bin/env bash
# Screenshot helper for Hyprland — save to ~/Pictures/Screenshots and copy to clipboard.
# Usage: screenshot.sh [region|output|window]
set -euo pipefail

mode="${1:-region}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

case "$mode" in
  region)
    geom="$(slurp)" || exit 0          # cancelled selection -> quietly stop
    grim -g "$geom" "$file"
    ;;
  output)
    name="$(hyprctl -j activeworkspace | jq -r '.monitor')"
    grim -o "$name" "$file"
    ;;
  window)
    geom="$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
    grim -g "$geom" "$file"
    ;;
  *)
    echo "usage: screenshot.sh [region|output|window]" >&2
    exit 1
    ;;
esac

wl-copy < "$file"
command -v notify-send >/dev/null && notify-send "Screenshot saved" "${file##*/}" -i "$file" || true
