# platform.zsh — sourced first, sets OS_TYPE and platform-specific env
case "$(uname -s)" in
  Darwin)
    export OS_TYPE="macos"
    # Guard: login shells already ran brew shellenv via .zprofile — avoid double PATH entries
    [[ -z "$HOMEBREW_PREFIX" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
  Linux)
    export OS_TYPE="linux"
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac
