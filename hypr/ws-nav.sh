#!/usr/bin/env bash
# Per-monitor workspace navigation by VISIBLE POSITION on the focused monitor.
#
# Why this exists: split-monitor-workspaces' `split-workspace N` is *block-based* — it
# always targets the focused monitor's assigned block (e.g. with monitor_priority the 3rd
# monitor owns workspaces 19-27), regardless of what's actually shown. When you unplug a
# monitor, its workspaces migrate onto the survivor but are NOT in the survivor's block, so
# split-workspace can't reach them and `Super+N` no longer matches the bar's Nth label.
#
# This helper instead navigates the workspaces *currently on the focused monitor*, sorted by
# id (== Noctalia's per-output label order). In normal multi-monitor use this is identical to
# split-workspace (a monitor only holds its own block); after a disconnect it correctly reaches
# the migrated workspaces too. The plugin still owns per-monitor workspace creation/persistence.
#
#   ws-nav.sh go N         focus the Nth workspace on the focused monitor
#   ws-nav.sh move N        move the active window to the Nth workspace (and follow it)
#   ws-nav.sh next|prev     focus next/previous workspace on the focused monitor (wraps)
#   ws-nav.sh movenext|moveprev   move the active window to next/previous (wraps)
set -euo pipefail

mode="${1:?usage: ws-nav.sh go|move N | next|prev | movenext|moveprev}"

mons="$(hyprctl -j monitors)"
mon="$(jq '[.[] | select(.focused)][0].id' <<<"$mons")"
active="$(jq --argjson m "$mon" '.[] | select(.id==$m) | .activeWorkspace.id' <<<"$mons")"

# Workspace ids on the focused monitor, ascending (matches the bar's left-to-right order)
mapfile -t ids < <(hyprctl -j workspaces | jq --argjson m "$mon" '.[] | select(.monitorID==$m) | .id' | sort -n)
count=${#ids[@]}
[ "$count" -eq 0 ] && exit 0

# Index of the currently-active workspace within that list
cur=0
for i in "${!ids[@]}"; do [ "${ids[$i]}" -eq "$active" ] && { cur=$i; break; }; done

case "$mode" in
  go|move)
    n="${2:?need a workspace number}"
    if [ "$n" -ge 1 ] && [ "$n" -le "$count" ]; then
      target="${ids[$((n-1))]}"
      [ "$mode" = move ] && hyprctl dispatch movetoworkspace "$target" || hyprctl dispatch workspace "$target"
    else
      # Asked for a position beyond what's on this monitor → let the plugin create the
      # Nth workspace in this monitor's block (keeps new workspaces monitor-local).
      [ "$mode" = move ] && hyprctl dispatch split-movetoworkspace "$n" || hyprctl dispatch split-workspace "$n"
    fi
    ;;
  next)     hyprctl dispatch workspace        "${ids[$(((cur+1)%count))]}" ;;
  prev)     hyprctl dispatch workspace        "${ids[$(((cur-1+count)%count))]}" ;;
  movenext) hyprctl dispatch movetoworkspace  "${ids[$(((cur+1)%count))]}" ;;
  moveprev) hyprctl dispatch movetoworkspace  "${ids[$(((cur-1+count)%count))]}" ;;
  *) echo "ws-nav.sh: unknown mode '$mode'" >&2; exit 1 ;;
esac
