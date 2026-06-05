#!/usr/bin/env bash

# Read CPU package temperature
cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
cpu_temp=$((cpu_temp / 1000))

# Read GPU temperature (NVIDIA)
gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "N/A")

# Read motherboard sensors (gigabyte_wmi)
mb_temp=$(cat /sys/class/hwmon/hwmon2/temp1_input 2>/dev/null)
mb_temp=$((mb_temp / 1000))

# Read NVMe temperatures
nvme0_temp=$(cat /sys/class/hwmon/hwmon0/temp1_input 2>/dev/null)
nvme0_temp=$((nvme0_temp / 1000))
nvme1_temp=$(cat /sys/class/hwmon/hwmon1/temp1_input 2>/dev/null)
nvme1_temp=$((nvme1_temp / 1000))

# Determine icon based on CPU temp
if [ "$cpu_temp" -ge 80 ]; then
    icon=""
    class="critical"
elif [ "$cpu_temp" -ge 70 ]; then
    icon=""
    class="warning"
elif [ "$cpu_temp" -ge 60 ]; then
    icon=""
    class="high"
elif [ "$cpu_temp" -ge 45 ]; then
    icon=""
    class="normal"
else
    icon=""
    class="cool"
fi

# Build tooltip
tooltip="<b>System Temperatures</b>\n"
tooltip+="───────────────\n"
tooltip+="  CPU Package:  ${cpu_temp}°C\n"
tooltip+="󰢮  GPU (NVIDIA): ${gpu_temp}°C\n"
tooltip+="󰍛  Motherboard:  ${mb_temp}°C\n"
tooltip+="───────────────\n"
tooltip+="󰋊  NVMe Drive 1: ${nvme0_temp}°C\n"
tooltip+="󰋊  NVMe Drive 2: ${nvme1_temp}°C"

# Output JSON for Waybar
printf '{"text": "%s %s°C | 󰢮 %s°C", "tooltip": "%s", "class": "%s"}\n' \
    "$icon" "$cpu_temp" "$gpu_temp" "$tooltip" "$class"
