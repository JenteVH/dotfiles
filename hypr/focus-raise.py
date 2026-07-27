#!/usr/bin/env python3
import os
import socket
import subprocess

runtime = os.environ["XDG_RUNTIME_DIR"]
sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
path = f"{runtime}/hypr/{sig}/.socket2.sock"

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(path)

buf = b""
while True:
    data = s.recv(4096)
    if not data:
        break
    buf += data
    while b"\n" in buf:
        line, buf = buf.split(b"\n", 1)
        if line.startswith(b"activewindowv2>>") and not line.endswith(b">>"):
            subprocess.run(
                ["hyprctl", "dispatch", "alterzorder", "top"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )