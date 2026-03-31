# ~/.zshrc — managed by ~/.dotfiles
# Symlinked: ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc

export DOTFILES="$HOME/.dotfiles"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load in order: platform first (sets OS_TYPE + brew), then path/env, then shell behaviour
source "$DOTFILES/zsh/platform.zsh"
source "$DOTFILES/zsh/path.zsh"
source "$DOTFILES/zsh/env.zsh"
source "$DOTFILES/zsh/options.zsh"
source "$DOTFILES/zsh/history.zsh"
source "$DOTFILES/zsh/plugins.zsh"

# Machine-local config and secrets — not tracked in git
[[ -f "$DOTFILES/zsh/local.zsh" ]] && source "$DOTFILES/zsh/local.zsh"

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh