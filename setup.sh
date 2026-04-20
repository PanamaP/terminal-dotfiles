#!/usr/bin/env bash
# setup.sh — Symlink dotfiles to the correct locations on macOS/Linux
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        echo "  Removing existing symlink: $dst"
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "  Backing up existing: $dst → ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  ✔ Linked: $dst → $src"
}

echo "Setting up dotfiles from: $DOTFILES_DIR"
echo ""

echo "[Neovim]"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "[WezTerm]"
# Clean up old single-file symlink if it exists
if [ -L "$HOME/.wezterm.lua" ]; then
    echo "  Removing old symlink: $HOME/.wezterm.lua"
    rm "$HOME/.wezterm.lua"
elif [ -f "$HOME/.wezterm.lua" ]; then
    echo "  Backing up old config: $HOME/.wezterm.lua → $HOME/.wezterm.lua.bak"
    mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak"
fi
link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"

echo "[Nushell]"
link "$DOTFILES_DIR/nushell/config.nu" "$HOME/.config/nushell/config.nu"
link "$DOTFILES_DIR/nushell/env.nu" "$HOME/.config/nushell/env.nu"

echo ""
echo "Done! Open nvim to trigger first-time plugin installation."
