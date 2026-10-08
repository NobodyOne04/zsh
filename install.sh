#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P10K_DIR="$HOME/.local/share/powerlevel10k"

echo "→ Installing Zsh config..."

# ─────────────────────────────────────────────
# Install Zsh
# ─────────────────────────────────────────────

if ! command -v zsh >/dev/null 2>&1; then
    echo "→ Zsh is not installed"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "Error: Homebrew is required to install Zsh on macOS"
            exit 1
        fi

        brew install zsh

    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed zsh

    elif command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y zsh

    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh

    else
        echo "Error: unsupported OS/package manager"
        exit 1
    fi
fi

# ─────────────────────────────────────────────
# Install Powerlevel10k
# ─────────────────────────────────────────────

if [[ ! -d "$P10K_DIR" ]]; then
    echo "→ Installing Powerlevel10k..."

    mkdir -p "$(dirname "$P10K_DIR")"

    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$P10K_DIR"
else
    echo "→ Powerlevel10k already installed"
fi

# ─────────────────────────────────────────────
# Backup existing configs
# ─────────────────────────────────────────────

backup_file() {
    local file="$1"

    if [[ -f "$file" && ! -L "$file" ]]; then
        echo "→ Backing up $file"
        mv "$file" "$file.backup.$(date +%Y%m%d%H%M%S)"
    fi
}

backup_file "$HOME/.zshrc"
backup_file "$HOME/.p10k.zsh"

# ─────────────────────────────────────────────
# Create symlinks
# ─────────────────────────────────────────────

echo "→ Linking .zshrc..."
ln -sfn "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

echo "→ Linking .p10k.zsh..."
ln -sfn "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# ─────────────────────────────────────────────
# Make Zsh the default shell
# ─────────────────────────────────────────────

ZSH_PATH="$(command -v zsh)"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "→ Setting Zsh as default shell..."

    if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "$ZSH_PATH" "$USER" || \
        echo "⚠ Could not change default shell automatically"
fi

echo ""
echo "✓ Zsh installed"
echo "✓ Powerlevel10k installed"
echo "✓ .zshrc linked"
echo "✓ .p10k.zsh linked"
echo ""
echo "Restart your shell or run:"
echo "  exec zsh"
