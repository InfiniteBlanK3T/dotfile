#!/bin/bash
# bootstrap.sh — set up dotfiles on macOS or Fedora
#
# Usage:
#   bash ~/.dotfiles/bootstrap.sh           # full setup (installs packages + symlinks)
#   bash ~/.dotfiles/bootstrap.sh --links   # symlinks only, skip package install
#
# Safe on existing machines: existing files are backed up, never silently overwritten.
set -e

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
LINKS_ONLY=false

[[ "${1:-}" == "--links" ]] && LINKS_ONLY=true

# ── Helpers ──────────────────────────────────────────────────────────────────

# safe_symlink <source> <target>
# - If target already points to source: skip (idempotent)
# - If target is an existing file/symlink pointing elsewhere: back it up first
# - Then create the symlink
safe_symlink() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "    [skip]   $dest (already correct)"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
    echo "    [backup] $dest → $BACKUP_DIR/$(basename "$dest")"
  fi

  ln -s "$src" "$dest"
  echo "    [linked] $dest → $src"
}

# ── OS detection ─────────────────────────────────────────────────────────────
OS_TYPE="$(uname -s)"

if [[ "$LINKS_ONLY" == false ]]; then
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "==> Detected macOS"

    if ! command -v brew &>/dev/null; then
      echo "==> Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    echo "==> Installing packages via Homebrew..."
    brew install fzf zoxide direnv neovim

  elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "==> Detected Linux"

    if command -v dnf &>/dev/null; then
      echo "==> Installing packages via dnf (Fedora)..."
      sudo dnf install -y fzf zoxide direnv neovim zsh
    else
      echo "==> Non-Fedora Linux detected. Please install manually: fzf zoxide direnv neovim zsh"
    fi

  else
    echo "ERROR: Unsupported OS: $OS_TYPE"
    exit 1
  fi

  # ── Oh My Zsh ──────────────────────────────────────────────────────────────
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
fi

# ── Symlinks ─────────────────────────────────────────────────────────────────
echo "==> Symlinking dotfiles..."

safe_symlink "$DOTFILES/zsh/.zshrc"     "$HOME/.zshrc"
safe_symlink "$DOTFILES/zsh/.zprofile"  "$HOME/.zprofile"
safe_symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
  echo ""
  echo "    Existing files were backed up to: $BACKUP_DIR"
fi

# ── Machine-local secrets init ───────────────────────────────────────────────
if [[ ! -f "$DOTFILES/zsh/local.zsh" ]]; then
  cp "$DOTFILES/zsh/local.zsh.example" "$DOTFILES/zsh/local.zsh"
  echo ""
  echo "==> Created zsh/local.zsh from example."
  echo "    Edit it to add your machine-specific secrets and config:"
  echo "    $DOTFILES/zsh/local.zsh"
fi

echo ""
echo "==> Done! Restart your shell or run: source ~/.zshrc"
echo ""
echo "    Reminders:"
echo "    - VS Code CLI: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
echo "    - Fill in secrets: $DOTFILES/zsh/local.zsh"

