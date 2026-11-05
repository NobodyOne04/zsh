#!/bin/sh
# Move `export NAME=...` lines whose NAME looks like a credential
# (…KEY, …TOKEN, …SECRET, …PASSWORD, …CREDENTIALS) from an old zshrc into
# the git-ignored secrets file (mode 600). Prints names only, never values.
set -eu
src=${1:?usage: migrate-secrets.sh OLD_ZSHRC}
dst=${XDG_CONFIG_HOME:-$HOME/.config}/zsh/secrets.zsh
[ -f "$src" ] || exit 0

mkdir -p "$(dirname "$dst")"
touch "$dst"
chmod 600 "$dst"

pattern='^[[:space:]]*export[[:space:]]+[A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD|PASSWD|CREDENTIALS?)[A-Z0-9_]*='
grep -E "$pattern" "$src" | while IFS= read -r line; do
    name=$(printf '%s\n' "$line" | sed -E 's/^[[:space:]]*export[[:space:]]+([A-Z0-9_]+)=.*/\1/')
    if grep -q "^export $name=" "$dst"; then
        echo "  kept    $name (already in secrets file)"
    else
        printf '%s\n' "$line" | sed -E 's/^[[:space:]]+//' >> "$dst"
        echo "  moved   $name -> $dst"
    fi
done
