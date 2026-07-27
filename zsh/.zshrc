# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh

# Disable zsh command autocorrection prompts.
unsetopt correct
unsetopt correct_all

if [[ "${DOCKER_HOST:-}" == "unix://${XDG_RUNTIME_DIR:-/run/user/$UID}/podman/podman.sock" ]]; then
  unset DOCKER_HOST
fi

# direnv
eval "$(direnv hook zsh)"

if [[ -d "$HOME/.lando/bin" && ":$PATH:" != *":$HOME/.lando/bin:"* ]]; then
  export PATH="$HOME/.lando/bin:$PATH"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Default editor (used by lazysql external editor, git, etc.)
export EDITOR=nvim
export VISUAL=nvim

# Local binaries (e.g. self-built lazysql in ~/Documents/OSS) take precedence
if [[ -d "$HOME/go/bin" && ":$PATH:" != *":$HOME/go/bin:"* ]]; then
  export PATH="$HOME/go/bin:$PATH"
fi

# pipx / pip --user binaries (conan, etc.)
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/.cargo/bin" && ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# Machine-local secrets and overrides (not version-controlled)
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local