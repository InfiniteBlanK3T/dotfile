# dotfiles

Personal shell configuration for macOS and Fedora. Built on Zsh + Oh My Zsh with a modular structure — each concern lives in its own file, platform differences are isolated, and secrets stay off Git.

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
    ├── platform.zsh      # OS detection, Homebrew (macOS) / local bin (Linux)
    ├── path.zsh          # PATH configuration
    ├── env.zsh           # Environment variables (non-secret)
    ├── options.zsh       # Zsh behaviour options
    ├── history.zsh       # History settings
    ├── plugins.zsh       # Oh My Zsh plugins + tool hooks (fzf, zoxide, direnv)
    ├── local.zsh         # Machine-local secrets and overrides — NOT committed
    └── local.zsh.example # Template for local.zsh
```

## Quick Setup

### New machine (fresh)

```bash
git clone https://github.com/<you>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash bootstrap.sh
```

`bootstrap.sh` will:
1. Install Homebrew (macOS) or use `dnf` (Fedora)
2. Install `fzf`, `zoxide`, `direnv`, `neovim`
3. Install Oh My Zsh if not already present
4. Symlink `~/.zshrc` and `~/.gitconfig` into the dotfiles
5. Create `zsh/local.zsh` from `local.zsh.example` if it doesn't exist

After bootstrap, restart your shell or run `source ~/.zshrc`.

### Existing machine (already has .zshrc, .gitconfig, etc.)

**Nothing is silently overwritten.** The bootstrap script will detect existing files, back them up with a timestamp, and then create the symlinks:

```
[backup] ~/.zshrc → ~/.dotfiles-backup/20260331_143022/.zshrc
[linked] ~/.zshrc → ~/.dotfiles/zsh/.zshrc
```

Backups land in `~/.dotfiles-backup/<timestamp>/` so you can always recover.

```bash
git clone https://github.com/<you>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash bootstrap.sh
```

To review what was backed up:
```bash
ls ~/.dotfiles-backup/
```

To run only the symlink step (skip package installs, useful on an existing machine):
```bash
bash bootstrap.sh --links
```

**Recommended workflow for existing machines:**
1. Run `bash bootstrap.sh --links` first to see what gets backed up and linked
2. Diff your backup against the dotfiles to carry over any personal config you want to keep:
   ```bash
   diff ~/.dotfiles-backup/<timestamp>/.zshrc ~/.dotfiles/zsh/.zshrc
   ```
3. Move machine-specific values (tokens, `KUBECONFIG`, etc.) into `zsh/local.zsh`
4. Run `source ~/.zshrc` to apply

## Platform Support

| File           | macOS | Fedora |
|----------------|-------|--------|
| `platform.zsh` | Homebrew shellenv | `~/.local/bin` in PATH |
| `path.zsh`     | VS Code CLI path | — |
| `plugins.zsh`  | fzf, zoxide, direnv (guarded) | fzf, zoxide, direnv (guarded) |
| `bootstrap.sh` | `brew install` | `dnf install` |

Tool hooks use `command -v` guards — the shell won't error if a tool isn't installed yet.

## zsh File Load Order

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

| Tool      | Purpose                              |
|-----------|--------------------------------------|
| `fzf`     | Fuzzy finder — Ctrl+R, Ctrl+T        |
| `zoxide`  | Smarter `cd` with frecency           |
| `direnv`  | Per-directory environment variables  |
| `neovim`  | Editor                               |
