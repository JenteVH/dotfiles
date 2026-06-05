#!/usr/bin/env python3
"""Fast Hyprland workspaces for Waybar - direct IPC listener, no blocking queries on updates."""

import json
import os
import socket
import subprocess
import sys

# Get monitor this waybar instance is on
MONITOR = os.environ.get("WAYBAR_OUTPUT_NAME", "")


def hyprctl(cmd):
    """Run hyprctl command and return JSON output."""
    result = subprocess.run(["hyprctl", cmd, "-j"], capture_output=True, text=True)
    return json.loads(result.stdout) if result.stdout else {}


def format_output(active, workspaces):
    """Format workspaces for Waybar custom module."""
    parts = []
    for ws in sorted(workspaces):
        label = ((ws - 1) % 5) + 1
        if ws == active:
            parts.append(
                f"<span bgcolor='#313244' color='#89b4fa' font_weight='bold'> {label} </span>"
            )
        else:
            parts.append(f"<span bgcolor='#1e1e2e' color='#585b70'> {label} </span>")

    output = {"text": " ".join(parts), "class": "workspaces"}
    print(json.dumps(output), flush=True)


def get_workspaces_for_monitor(workspaces_data):
    """Filter workspaces for current monitor."""
    if not MONITOR:
        return set(ws["id"] for ws in workspaces_data if ws.get("id", 0) > 0)
    return set(
        ws["id"]
        for ws in workspaces_data
        if ws.get("id", 0) > 0 and ws.get("monitor") == MONITOR
    )


def main():
    # Get initial state (only IPC calls at startup)
    active = hyprctl("activeworkspace").get("id", 1)
    workspaces_data = hyprctl("workspaces")
    workspaces = get_workspaces_for_monitor(workspaces_data)

    format_output(active, workspaces)

    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    socket_path = f"{os.environ.get('XDG_RUNTIME_DIR')}/hypr/{sig}/.socket2.sock"

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(socket_path)

    buffer = ""
    while True:
        data = sock.recv(4096).decode("utf-8")
        if not data:
            break

        buffer += data
        while "\n" in buffer:
            line, buffer = buffer.split("\n", 1)
            if ">>" not in line:
                continue

            event, payload = line.split(">>", 1)

            if event == "workspacev2":
                try:
                    ws_id = int(payload.split(",")[0])
                    if ws_id in workspaces:
                        active = ws_id
                        format_output(active, workspaces)
                except ValueError:
                    pass

            elif event == "createworkspacev2":
                try:
                    ws_id = int(payload.split(",")[0])
                    if ws_id > 0:
                        ws_data = hyprctl("workspaces")
                        for ws in ws_data:
                            if ws.get("id") == ws_id:
                                if not MONITOR or ws.get("monitor") == MONITOR:
                                    workspaces.add(ws_id)
                                    format_output(active, workspaces)
                                break
                except ValueError:
                    pass

            elif event == "destroyworkspacev2":
                try:
                    ws_id = int(payload.split(",")[0])
                    if ws_id in workspaces:
                        workspaces.discard(ws_id)
                        format_output(active, workspaces)
                except ValueError:
                    pass

            elif event == "focusedmonv2":
                try:
                    mon, ws_id_str = payload.split(",")
                    ws_id = int(ws_id_str)
                    if mon == MONITOR and ws_id in workspaces:
                        active = ws_id
                        format_output(active, workspaces)
                except (ValueError, IndexError):
                    pass


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
    except BrokenPipeError:
        sys.exit(0)
