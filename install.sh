#!/usr/bin/env bash

set -e

echo "→ Installing Zsh config..."

# Backup existing config
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    echo "→ Backing up existing ~/.zshrc"
    mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi

ln -sfn "$(pwd)/.zshrc" "$HOME/.zshrc"

echo "✓ Zsh config installed"
