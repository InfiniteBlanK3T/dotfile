#!/bin/bash
# bootstrap.sh — set up dotfiles on macOS, Fedora, or Termux (Android)
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
# Termux sets TERMUX_VERSION and reports uname -s as "Linux"; detect it first.
IS_TERMUX=false
[[ -n "${TERMUX_VERSION:-}" ]] && IS_TERMUX=true

OS_TYPE="$(uname -s)"

if [[ "$LINKS_ONLY" == false ]]; then
  if [[ "$IS_TERMUX" == true ]]; then
    echo "==> Detected Termux (Android)"
    echo "==> Installing packages via pkg..."
    pkg update -y
    pkg install -y zsh git curl fzf zoxide direnv neovim unzip

  elif [[ "$OS_TYPE" == "Darwin" ]]; then
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
      sudo dnf install -y fzf zoxide direnv neovim zsh unzip curl git fontconfig
    else
      echo "==> Non-Fedora Linux detected. Please install manually: fzf zoxide direnv neovim zsh unzip curl git fontconfig"
    fi

  else
    echo "ERROR: Unsupported OS: $OS_TYPE"
    exit 1
  fi

  # ── Default shell ──────────────────────────────────────────────────────────
  # Installing zsh does not change the login shell. Without this, new terminals
  # keep starting bash and ~/.zshrc is never read.
  if [[ "$IS_TERMUX" != true ]]; then
    ZSH_BIN="$(command -v zsh || true)"
    CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
    [[ -z "$CURRENT_SHELL" ]] && CURRENT_SHELL="$SHELL"

    if [[ -z "$ZSH_BIN" ]]; then
      echo "    [warn] zsh not found — skipping default shell change"
    elif [[ "$CURRENT_SHELL" == "$ZSH_BIN" ]]; then
      echo "    [skip]   Default shell is already $ZSH_BIN"
    else
      echo "==> Setting $ZSH_BIN as default shell..."
      if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
        echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
      fi
      chsh -s "$ZSH_BIN" || echo "    [warn] chsh failed — run manually: chsh -s $ZSH_BIN"
    fi
  fi

  # ── Oh My Zsh ──────────────────────────────────────────────────────────────
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "==> Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  # ── Powerlevel10k theme ────────────────────────────────────────────────────
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    echo "==> Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    echo "    [skip]   Powerlevel10k already installed"
  fi

  # ── Oh My Zsh plugins ─────────────────────────────────────────────────────
  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  else
    echo "    [skip]   zsh-autosuggestions already installed"
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "==> Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  else
    echo "    [skip]   zsh-syntax-highlighting already installed"
  fi

  # ── JetBrains Mono Nerd Font ──────────────────────────────────────────────
  JBMONO_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  install_font() {
    local tmp_dir font_dir
    tmp_dir="$(mktemp -d)" || return 1

    if [[ "$IS_TERMUX" == true ]]; then
      echo "==> Installing JetBrains Mono Nerd Font for Termux..."
      mkdir -p "$HOME/.termux"
      curl -fsSL "$JBMONO_URL" -o "$tmp_dir/JetBrainsMono.zip" || return 1
      unzip -p "$tmp_dir/JetBrainsMono.zip" "JetBrainsMonoNerdFont-Regular.ttf" > "$HOME/.termux/font.ttf" || return 1
      echo "    Font installed to ~/.termux/font.ttf"
      echo "    Run: termux-reload-settings  (or restart Termux) to apply the font"

    elif [[ "$OS_TYPE" == "Darwin" ]]; then
      echo "==> Installing JetBrains Mono Nerd Font via Homebrew Cask..."
      brew install --cask font-jetbrains-mono-nerd-font || return 1

    elif [[ "$OS_TYPE" == "Linux" ]]; then
      echo "==> Installing JetBrains Mono Nerd Font..."
      font_dir="$HOME/.local/share/fonts/JetBrainsMono"
      mkdir -p "$font_dir"
      curl -fsSL "$JBMONO_URL" -o "$tmp_dir/JetBrainsMono.zip" || return 1
      unzip -o "$tmp_dir/JetBrainsMono.zip" "*.ttf" -d "$font_dir" || return 1
      command -v fc-cache &>/dev/null && fc-cache -f "$font_dir"
      echo "    Font installed to $font_dir"
    fi

    rm -rf "$tmp_dir"
  }

  # The font is cosmetic — never let it abort the rest of the setup.
  install_font || echo "    [warn] Font install failed. Install JetBrainsMono Nerd Font manually if needed."
fi

# ── Symlinks ─────────────────────────────────────────────────────────────────
echo "==> Symlinking dotfiles..."

safe_symlink "$DOTFILES/zsh/.zshrc"     "$HOME/.zshrc"
safe_symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# SSH client config (public config only — never private keys)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
safe_symlink "$DOTFILES/ssh/config"     "$HOME/.ssh/config"

# .zprofile is for macOS/Linux login shells; Termux uses its own init system
if [[ "$IS_TERMUX" != true ]]; then
  safe_symlink "$DOTFILES/zsh/.zprofile"  "$HOME/.zprofile"
fi

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
echo "==> Done! Log out and back in (or run: exec zsh) to start using Zsh."
echo ""
echo "    Reminders:"
if [[ "$IS_TERMUX" == true ]]; then
  echo "    - Run 'termux-reload-settings' (or restart Termux) to apply the new font"
  echo "    - Run 'chsh -s zsh' if Zsh is not already your default shell"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  echo "    - VS Code CLI: Cmd+Shift+P → 'Shell Command: Install code command in PATH'"
  echo "    - Set your terminal font to 'JetBrainsMonoNerdFont' in terminal preferences"
else
  echo "    - Set your terminal font to 'JetBrainsMonoNerdFont' in terminal preferences"
fi
echo "    - Run 'p10k configure' to personalise your Powerlevel10k prompt"
echo "    - Fill in secrets: $DOTFILES/zsh/local.zsh"

