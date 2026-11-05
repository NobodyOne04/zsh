# General helpers.

mkcd() { mkdir -p -- "$1" && cd -- "$1" }

# extract any archive
extract() {
  [[ -f $1 ]] || { print -u2 "extract: no such file: $1"; return 1 }
  case ${1:l} in
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz|*.txz)   tar xJf "$1" ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip)            unzip -q "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.xz)             unxz "$1" ;;
    *.7z)             7z x "$1" ;;
    *) print -u2 "extract: unknown archive: $1"; return 1 ;;
  esac
}

# clipboard that works on macOS and Wayland: `cmd | clip`, `clip -o`
clip() {
  if (( IS_MAC )); then [[ $1 == -o ]] && pbpaste || pbcopy
  else [[ $1 == -o ]] && wl-paste || wl-copy; fi
}

# port <n>: who is listening on a port; ports: everything listening
port()  { lsof -nP -iTCP:"$1" -sTCP:LISTEN }
ports() { lsof -nP -iTCP -sTCP:LISTEN | awk 'NR==1 || !seen[$1 $9]++' }

myip()  { curl -fsS https://ifconfig.me; echo }
serve() { python3 -m http.server "${1:-8000}" }                 # serve the current dir
json()  { (( $# )) && jq . "$@" || jq . }                        # pretty JSON from file or pipe
b64e()  { print -n "$*" | base64 }
b64d()  { print -n "$*" | base64 -d; echo }
uuid()  { python3 -c 'import uuid; print(uuid.uuid4())' }
cheat() { curl -fsS "https://cht.sh/$*" }                        # cheat tar, cheat python/list

# venv: create (uv if available) and activate ./.venv; `venv` again just activates
venv() {
  if [[ ! -d .venv ]]; then
    if (( $+commands[uv] )); then uv venv -q .venv; else python3 -m venv .venv; fi
  fi
  source .venv/bin/activate
}

# fix-history: repair "zsh: corrupt history file" (e.g. after a hard power-off)
fix-history() {
  local f=${HISTFILE:-$HOME/.zsh_history} bak=${HISTFILE:-$HOME/.zsh_history}.corrupt-$(date +%Y%m%d-%H%M%S)
  [[ -f $f ]] || { print -u2 "no history file at $f"; return 1 }
  # drop NUL bytes and control characters (what a hard power-off leaves behind),
  # keep tabs, newlines and UTF-8 text
  mv "$f" "$bak" && LC_ALL=C tr -d '\000-\010\013\014\016-\037' < "$bak" > "$f" && chmod 600 "$f" && fc -R "$f" &&
    print -P "%F{cyan}›%f history repaired ($(( $(wc -l < "$f") )) lines kept); damaged copy: ${bak/#$HOME/~}"
}

# zbench: measure shell startup (10 runs)
zbench() {
  zmodload zsh/datetime
  local s; repeat ${1:-10} { s=$EPOCHREALTIME; zsh -i -c exit >/dev/null 2>&1; printf '%.0f ms\n' $(( (EPOCHREALTIME - s) * 1000 )) }
}

# secret-add NAME: store a credential in the git-ignored secrets file
# (prompted without echo, never in history or in this repo)
secret-add() {
  local name=$1 file=${ZSH_SECRETS_FILE:-$XDG_CONFIG_HOME/zsh/secrets.zsh} value
  [[ $name == [A-Z_][A-Z0-9_]# ]] || { print -u2 "usage: secret-add NAME (UPPER_CASE)"; return 1 }
  read -rs "value?$name: "; echo
  mkdir -p "${file:h}"; touch "$file"; chmod 600 "$file"
  sed -i.bak "/^export $name=/d" "$file" && rm -f "$file.bak"
  print -r -- "export $name=${(qq)value}" >> "$file"
  export "$name=$value"
  print -P "%F{cyan}›%f $name saved to ${file/#$HOME/~} (mode 600)"
}
