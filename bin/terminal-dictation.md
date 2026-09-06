# Terminal dictation

Focus the Codex CLI prompt in Kitty, press **Super+R**, and speak.
Press the same shortcut again to stop recording. A notification appears while
Whisper transcribes locally, then the text is copied and pasted into the terminal.
Review it and press Enter yourself. **Super+Shift+R** cancels recording or transcription.

The shortcut is included separately in Niri's main configuration, so it works with
both the QWERTY and Colemak keybinding sets. Niri reloads configuration changes automatically.

Uses the default PipeWire microphone (currently the RØDE XDM-100). Audio stays local.
The existing multilingual `ggml-large-v3-turbo-q5_0.bin` model detects the spoken language.
Inference uses the RTX 4090 through the Vulkan-enabled Whisper package. The same
3.7-second verification clip took 0.53 seconds through the dictation script, versus
about 16 seconds on the previous CPU backend, with the transcript unchanged. GPU shader
initialization is cached; the first run after a driver/cache change can be slower.
Recording stops automatically after three minutes. Temporary audio is removed when
the operation ends.

If focus changes to another window while transcribing, the text is only copied;
return to the terminal and press Ctrl+Shift+V. Text is also kept in the private file
`~/.cache/terminal-dictation/last.txt` until the next dictation replaces it.
Pasting replaces the current clipboard contents. No Enter key is generated.

The executable is `~/.local/bin/terminal-dictation`, linked to the script here.
Whisper (CPU and Vulkan builds), wtype, and wl-clipboard are retained as Nix GC roots under
`~/.local/share/terminal-dictation/deps`. No API key or network service is used.

Diagnostics:

```sh
terminal-dictation status
terminal-dictation cancel
terminal-dictation transcribe /path/to/16khz-mono.wav
```

Logs are at `~/.cache/terminal-dictation/{record,whisper}.log`.
`DICTATION_LANGUAGE=en` can select English explicitly;
`DICTATION_MODEL=/path/to/model.bin` selects a different Whisper model. To apply
these to the desktop shortcut, set them in Niri's environment block and restart the
session, or adjust the defaults at the top of the script.

To disable the shortcuts, remove the `cfg/dictation.kdl` include from `niri/config.kdl`.
