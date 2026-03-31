# Note: platform.zsh is sourced before this in .zshrc — OS_TYPE is already set.

# Safe baseline PATH (macOS and Linux)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# VS Code CLI (macOS only)
if [[ "$OS_TYPE" == "macos" ]]; then
	export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi