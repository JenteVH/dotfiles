#!/usr/bin/env bash
# Reconcile the internal panel (eDP-1) with the physical lid + dock state.
# Called on every lid-switch edge (bindl) and once at startup (exec-once).
#
# IMPORTANT — why lid-close does NOT unconditionally disable eDP-1:
#   Disabling the *only* connected output crashes Hyprland. When eDP-1 is the sole
#   monitor, `monitor = eDP-1, disable` tears down the Noctalia/quickshell layer
#   surfaces, and an in-flight touchpad touch event then dereferences a now-dead
#   surface -> SIGSEGV in CWLSurfaceResource::client() (seen in hyprlandCrashReport).
#   So we disable eDP-1 ONLY when an external monitor is present (docked). Undocked,
#   we leave the panel alone and let logind suspend the machine on lid-close
#   (HandleLidSwitch=suspend, the system default here).
#
# (Historical — geometry moved to monitors.conf via nwg-displays; pick scale 1.8 there.)
# Scale is 1.8: 2880/1.8 = 1600 and 1800/1.8 = 1000 (integer logical size).
# Hyprland rejects 1.75 (2880/1.75 = 1645.71, non-integer) with an "invalid scale"
# popup and auto-bumps it — that was the "1.75 / 1.80" message.
#
# NOTE: uses `hyprctl keyword`, which only works under the legacy hyprland.conf
# parser. If Hyprland is in --safe-mode (auto-entered after a crash) these calls
# no-op with "keyword can't work with non-legacy parsers" — exit safe mode first.

set -uo pipefail

RUNTIME=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} || ! -S $RUNTIME/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket.sock ]]; then
    for d in $(command ls -t "$RUNTIME/hypr" 2>/dev/null); do
        if [[ -S $RUNTIME/hypr/$d/.socket.sock ]]; then
            export HYPRLAND_INSTANCE_SIGNATURE=$d
            break
        fi
    done
fi

# TEMP DEBUG: trace every invocation (remove when lid issue is solved)
exec 2>>/tmp/lid-debug.log
echo "[$(date '+%F %T')] invoked: lid=$(cat /proc/acpi/button/lid/LID/state 2>&1 | awk '{print $2}') monitors=[$(hyprctl monitors all 2>&1 | grep '^Monitor' | tr '\n' ' ')]" >> /tmp/lid-debug.log
set -x

LID=/proc/acpi/button/lid/LID/state
INT=eDP-1

lid_open() { grep -q open "$LID" 2>/dev/null; }
# Docked = at least one connected output that is NOT the internal panel.
docked()   { hyprctl monitors all 2>/dev/null | grep -E '^Monitor ' | grep -qv 'Monitor eDP-1 '; }
# Superseded: geometry now lives in monitors.conf (written by nwg-displays, sourced
# by hyprland.conf) — this script no longer positions anything.
# at_dock()  { hyprctl monitors all 2>/dev/null | grep -q '^Monitor DP-1 '; }

if lid_open; then
    if ! docked && grep -q "ATNA33AA08-0,disable" "$HOME/.config/hypr/monitors.conf" 2>/dev/null; then
        hyprctl keyword monitor "$INT, preferred, auto, 1.8"
    else
        # Re-parse the config: undoes the lid-close disable below and re-asserts whatever
        # nwg-displays last saved to monitors.conf. No hardcoded geometry here anymore.
        hyprctl reload
        sleep 0.5
        hyprctl monitors | grep -q "^Monitor $INT " || hyprctl keyword monitor "$INT, preferred, auto, 1.8"
    fi
    # if at_dock; then
    #     hyprctl keyword monitor "$INT, 2880x1800@60, 2560x2160, 1.8"  # full dock: below DP-1
    # else
    #     hyprctl keyword monitor "$INT, 2880x1800@60, 0x0, 1.8"        # standalone or single external: left, at origin
    # fi
else
    if docked; then
        hyprctl keyword monitor "$INT, disable"  # externals carry the session; workspaces migrate
    fi
    # Undocked + lid shut: intentionally do nothing. logind suspends the machine;
    # disabling the sole output here is exactly what crashed Hyprland (see header).
fi