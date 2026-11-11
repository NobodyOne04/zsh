#!/usr/bin/env bash
# link.sh link|unlink|status: put this repo's configs in place as symlinks.
# An existing file is moved to <file>.bak-<date> first; `unlink` restores the
# newest backup. The old ~/.zshrc's credentials are moved to the secrets file.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
cfg=${XDG_CONFIG_HOME:-$HOME/.config}
stamp=$(date +%Y%m%d-%H%M%S)

# source (in this repo)    target
links=(
  "zshrc                   $HOME/.zshrc"
  "git/config              $cfg/git/config"
  "git/ignore              $cfg/git/ignore"
  "git/hooks               $cfg/git/hooks"
  "direnv/direnvrc         $cfg/direnv/direnvrc"
  "atuin/config.toml       $cfg/atuin/config.toml"
  "lazygit/config.yml      $cfg/lazygit/config.yml"
  "eza/theme.yml           $cfg/eza/theme.yml"
)

do_link() {
  local src=$repo/$1 dst=$2
  if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
    echo "  ok      ${dst/#$HOME/\~}"; return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst || -L $dst ]]; then
    mv "$dst" "$dst.bak-$stamp"
    echo "  backup  ${dst/#$HOME/\~} -> ${dst/#$HOME/\~}.bak-$stamp"
    [[ $1 == zshrc ]] && "$repo/scripts/migrate-secrets.sh" "$dst.bak-$stamp"
  fi
  ln -s "$src" "$dst"
  echo "  linked  ${dst/#$HOME/\~}"
}

do_unlink() {
  local src=$repo/$1 dst=$2 last
  [[ -L $dst && $(readlink "$dst") == "$src" ]] || return 0
  rm "$dst"
  last=$(ls -d "$dst".bak-* 2>/dev/null | sort | tail -1 || true)
  if [[ -n $last ]]; then mv "$last" "$dst"; echo "  restored ${dst/#$HOME/\~}"
  else echo "  removed  ${dst/#$HOME/\~}"; fi
}

do_status() {
  local src=$repo/$1 dst=$2
  if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then echo "  ok      ${dst/#$HOME/\~}"
  else echo "  missing ${dst/#$HOME/\~}  (make link)"; fi
}

action=${1:?usage: link.sh link|unlink|status}
for entry in "${links[@]}"; do
  read -r src dst <<<"$entry"
  "do_$action" "$src" "$dst"
done
