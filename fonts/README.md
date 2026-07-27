# Fonts

## Install

Run from the dotfiles repository root:

```sh
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
cp -R fonts/"AudioLink Mono" fonts/FiraFlott fonts/Flottflott "${XDG_DATA_HOME:-$HOME/.local/share}/fonts/"
fc-cache -f "${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
```

## Sources

- AudioLink Mono: https://github.com/llealloo/audiolink
- FiraFlott: https://github.com/kosimst/FiraFlott
- Flottflott: https://www.dafont.com/flottflott.font
