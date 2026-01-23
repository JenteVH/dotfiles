# Add ~/.local/bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# JetBrains Toolbox
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# Initialize Starship prompt
eval "$(starship init zsh)"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Better completion
autoload -Uz compinit && compinit

# Key bindings for autosuggestions
bindkey '^[[1;5C' forward-word        # Ctrl+Right (accept word from suggestion)
bindkey '^[[1;5D' backward-kill-word  # Ctrl+Left (delete previous word)
bindkey '^[f' forward-word            # Alt+F
bindkey '^[b' backward-word           # Alt+B

# Cycle through history with Ctrl+Up/Down based on what's typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[1;5A' up-line-or-beginning-search    # Ctrl+Up
bindkey '^[[1;5B' down-line-or-beginning-search  # Ctrl+Down

# direnv hook for automatic environment loading
eval "$(direnv hook zsh)"
