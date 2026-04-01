# .zprofile — login shell only
# Homebrew must be available early for other login-shell scripts.
# Everything else (PATH, env, tools) is handled in .zshrc via platform.zsh.
eval "$(/opt/homebrew/bin/brew shellenv)"
