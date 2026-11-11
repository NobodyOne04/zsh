# Environment and PATH. Runs first; spawns no processes.

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
typeset -g ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p "$ZSH_CACHE_DIR/completions"

export EDITOR=nvim VISUAL=nvim
# sops reads the age key from the same place on macOS and Linux
export SOPS_AGE_KEY_FILE=$XDG_CONFIG_HOME/sops/age/keys.txt
export PAGER=less LESS='-R -F -i -M'
export LANG=${LANG:-en_US.UTF-8}

typeset -g IS_MAC=0 IS_LINUX=0
[[ $OSTYPE == darwin* ]] && IS_MAC=1 || IS_LINUX=1

# PATH: `-U` keeps entries unique (the old config ended up with 3,249
# entries, 21 unique). Missing directories are dropped by (N-/).
typeset -gU path fpath
export GOPATH=${GOPATH:-$HOME/go}          # was $(go env GOPATH): a process per shell
path=(
  $HOME/.local/bin
  $GOPATH/bin
  $HOME/.cargo/bin
  ${KREW_ROOT:-$HOME/.krew}/bin
  $path
)
if (( IS_MAC )); then
  path=(/opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/libpq/bin $path)
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
  # psql client libraries (psycopg etc. build against keg-only libpq)
  if [[ -d /opt/homebrew/opt/libpq ]]; then
    export LDFLAGS="-L/opt/homebrew/opt/libpq/lib" CPPFLAGS="-I/opt/homebrew/opt/libpq/include"
  fi
fi
path=(${^path}(N-/))
fpath=($ZSH_CACHE_DIR/completions ${^fpath}(N-/))

# fzf look: archminimal palette
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --info=inline-right
  --prompt='› ' --pointer='▍' --marker='●'
  --color=bg+:#1d3a45,bg:-1,fg:#d0d2d0,fg+:#ffffff,hl:#00e5ff,hl+:#00e5ff
  --color=border:#3a3c44,prompt:#00e5ff,pointer:#00e5ff,marker:#00e5ff,info:#7d8088,header:#7d8088,spinner:#00e5ff"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || cat {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=auto {}'"

# eza's theme (eza/theme.yml, linked here); macOS would look in ~/Library/Application Support
export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza
export BAT_THEME=${BAT_THEME:-ansi}
export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # colored man pages (when bat exists)
(( $+commands[bat] )) || unset MANPAGER
