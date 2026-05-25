# dotfiles

Personal shell configuration for macOS, Fedora, and Termux (Android). Built on Zsh + Oh My Zsh with a modular structure — each concern lives in its own file, platform differences are isolated, and secrets stay off Git.

## Structure

```
.dotfiles/
├── bootstrap.sh          # One-command setup for a new machine
├── .gitignore
├── git/
│   └── .gitconfig        # Git identity and preferences
├── ssh/
│   └── config            # SSH client config (no private keys)
└── zsh/
    ├── .zshrc            # Entry point — symlinked to ~/.zshrc
    ├── .zprofile         # Login shell — Homebrew init (macOS only, guarded)
    ├── platform.zsh      # OS detection: macOS / Fedora / Termux
    ├── path.zsh          # PATH configuration
    ├── env.zsh           # Environment variables (non-secret)
    ├── options.zsh       # Zsh behaviour options
    ├── history.zsh       # History settings
    ├── plugins.zsh       # Oh My Zsh plugins + tool hooks (fzf, zoxide, direnv)
    ├── local.zsh         # Machine-local secrets and overrides — NOT committed
    └── local.zsh.example # Template for local.zsh
```

## Quick Setup

### macOS / Fedora

```bash
git clone https://github.com/InfiniteBlanK3T/dotfile.git ~/.dotfiles
cd ~/.dotfiles
bash bootstrap.sh
```

### Termux (Android)

```bash
pkg install -y git
git clone https://github.com/InfiniteBlanK3T/dotfile.git ~/.dotfiles
cd ~/.dotfiles
bash bootstrap.sh
```

`bootstrap.sh` will:
1. Install packages via the platform package manager (Homebrew / dnf / pkg)
2. Install Oh My Zsh
3. Clone Powerlevel10k theme and the `zsh-autosuggestions` / `zsh-syntax-highlighting` plugins
4. Install JetBrains Mono Nerd Font for the current platform
5. Symlink `~/.zshrc` and `~/.gitconfig` (and `~/.zprofile` on macOS/Linux)
6. Create `zsh/local.zsh` from `local.zsh.example` if it doesn't exist

After bootstrap, restart your shell or run `source ~/.zshrc`, then run `p10k configure` to personalise your prompt.

### Existing machine (already has .zshrc, .gitconfig, etc.)

**Nothing is silently overwritten.** The bootstrap script will detect existing files, back them up with a timestamp, and then create the symlinks:

```
[backup] ~/.zshrc → ~/.dotfiles-backup/20260331_143022/.zshrc
[linked] ~/.zshrc → ~/.dotfiles/zsh/.zshrc
```

Backups land in `~/.dotfiles-backup/<timestamp>/` so you can always recover.

To run only the symlink step (skip package installs, useful on an existing machine):
```bash
bash bootstrap.sh --links
```

**Recommended workflow for existing machines:**
1. Run `bash bootstrap.sh --links` first to see what gets backed up and linked
2. Diff your backup against the dotfiles to carry over any personal config:
   ```bash
   diff ~/.dotfiles-backup/<timestamp>/.zshrc ~/.dotfiles/zsh/.zshrc
   ```
3. Move machine-specific values (tokens, `KUBECONFIG`, etc.) into `zsh/local.zsh`
4. Run `source ~/.zshrc` to apply

## Platform Support

| File           | macOS | Fedora | Termux (Android) |
|----------------|-------|--------|------------------|
| `platform.zsh` | Homebrew shellenv | `~/.local/bin` in PATH | `$PREFIX/bin` in PATH |
| `path.zsh`     | VS Code CLI path | — | skips standard Unix paths |
| `.zprofile`    | Homebrew init (guarded) | symlinked (no-op) | not symlinked |
| `plugins.zsh`  | fzf, zoxide, direnv (guarded) | fzf, zoxide, direnv (guarded) | fzf, zoxide, direnv (guarded) |
| `bootstrap.sh` | `brew install` | `dnf install` | `pkg install` (no sudo) |
| Font install   | Homebrew Cask | `~/.local/share/fonts/` + `fc-cache` | `~/.termux/font.ttf` |

Tool hooks use `command -v` guards — the shell won't error if a tool isn't installed yet.

## Theme & Prompt

The dotfiles ship with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) as the Zsh theme. Bootstrap clones it automatically. **Prompt style is intentionally left unconfigured** — run the wizard yourself after setup:

```zsh
p10k configure
```

Your choices are saved to `~/.p10k.zsh` (not tracked by this repo, so each machine has its own layout).

## Nerd Font

Bootstrap installs [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip) automatically:

| Platform | Location | Activation |
|----------|----------|------------|
| macOS | system font (Homebrew Cask) | select in terminal preferences |
| Fedora | `~/.local/share/fonts/JetBrainsMono/` | automatic via `fc-cache` |
| Termux | `~/.termux/font.ttf` | run `termux-reload-settings` or restart Termux |

After installing the font, set **JetBrainsMono Nerd Font** as your terminal's font face to unlock all Powerlevel10k glyphs.

## Zsh File Load Order

```
.zshrc
  └── platform.zsh   # 1. OS type + package manager env
  └── path.zsh       # 2. PATH (depends on OS_TYPE from platform.zsh)
  └── env.zsh        # 3. Environment variables
  └── options.zsh    # 4. Zsh setopt flags
  └── history.zsh    # 5. History config
  └── plugins.zsh    # 6. Oh My Zsh + tool hooks
  └── local.zsh      # 7. Machine-local overrides (if exists)
```

## Machine-Local Config

Secrets, tokens, and machine-specific variables go in `zsh/local.zsh`. This file is gitignored and never committed. Copy the template to get started:

```bash
cp ~/.dotfiles/zsh/local.zsh.example ~/.dotfiles/zsh/local.zsh
```

Edit it to add machine-specific values:
```zsh
export KUBECONFIG=~/.kube/config-homelab-k3s
export MY_API_TOKEN="..."
```

`local.zsh` is sourced last, so it can override anything set in the other files.

## Tools Installed

| Tool      | Purpose                              | macOS | Fedora | Termux |
|-----------|--------------------------------------|-------|--------|--------|
| `fzf`     | Fuzzy finder — Ctrl+R, Ctrl+T        | ✓ | ✓ | ✓ |
| `zoxide`  | Smarter `cd` with frecency           | ✓ | ✓ | ✓ |
| `direnv`  | Per-directory environment variables  | ✓ | ✓ | ✓ |
| `neovim`  | Editor                               | ✓ | ✓ | ✓ |

