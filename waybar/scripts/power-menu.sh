#!/usr/bin/env bash

# Power menu options
options="Logout\nShutdown\nReboot\nSuspend"

# Show rofi menu and get selection
selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 200px;}')

# Execute based on selection
case $selected in
    "Logout")
        hyprctl dispatch exit
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Suspend")
        systemctl suspend
        ;;
esac
