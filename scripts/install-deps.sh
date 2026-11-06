#!/usr/bin/env bash
# Shell essentials (+ optional devops tools with --devops).
set -euo pipefail

core_arch=(zsh git fzf zoxide eza fd ripgrep bat direnv lazygit btop tldr git-delta jq less atuin gitleaks sops age)
core_brew=(zsh git fzf zoxide eza fd ripgrep bat direnv lazygit btop tldr git-delta jq atuin gitleaks sops age)
devops_arch=(kubectl helm k9s terraform aws-cli-v2 docker docker-compose docker-buildx yq)
devops_brew=(kubectl helm k9s terraform awscli yq)

devops=0
[[ ${1:-} == --devops ]] && devops=1

if [[ $OSTYPE == darwin* ]]; then
    command -v brew >/dev/null || { echo "Homebrew is required"; exit 1; }
    brew install "${core_brew[@]}"
    (( devops )) && brew install "${devops_brew[@]}"
elif command -v pacman >/dev/null; then
    sudo pacman -S --needed "${core_arch[@]}"
    (( devops )) && sudo pacman -S --needed "${devops_arch[@]}"
else
    echo "Unsupported system: install these yourself: ${core_brew[*]}"; exit 1
fi
echo "Font: the prompt and eza icons need a Nerd Font (e.g. ttf-jetbrains-mono-nerd / font-jetbrains-mono-nerd-font)."
