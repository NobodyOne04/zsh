# Tool integrations. `eval "$(tool init zsh)"` starts a process every shell;
# instead the output is cached and regenerated only when the tool changes.

# _cached_source <name> <command…>
_cached_source() {
  local name=$1; shift
  (( $+commands[$1] )) || return 0
  local cache=$ZSH_CACHE_DIR/$name.zsh
  if [[ ! -s $cache || $commands[$1] -nt $cache ]]; then
    "$@" >| "$cache" 2>/dev/null
    zcompile "$cache" 2>/dev/null
  fi
  source "$cache"
}

# _cached_completion <cmd> <command…>: writes _<cmd> into the completions dir
# (in fpath before compinit). Generated in the background the first time.
_cached_completion() {
  local cmd=$1; shift
  (( $+commands[$cmd] )) || return 0
  local file=$ZSH_CACHE_DIR/completions/_$cmd
  [[ -s $file && ! $commands[$cmd] -nt $file ]] && return 0
  { "$@" >| "$file.tmp" 2>/dev/null && mv -f "$file.tmp" "$file" } &!
}

_cached_source zoxide  zoxide init zsh                 # z <dir>, zi (interactive)
_cached_source fzf     fzf --zsh                       # Ctrl-T files, Ctrl-R history, Alt-C cd
# atuin's init runs `atuin uuid` (a process, ~10 ms) unless a session id is set: make the
# same UUIDv7 (ms timestamp, version 7, random) here instead.
# shortcut: $RANDOM, not crypto-grade; fine for a session id. Drop this if atuin changes the format.
if (( $+commands[atuin] )) && [[ -z $ATUIN_SESSION || $ATUIN_SHLVL != $SHLVL ]]; then
  zmodload zsh/datetime
  typeset -i _ms=$(( EPOCHREALTIME * 1000 ))
  printf -v ATUIN_SESSION '%012x7%03x%x%03x%04x%04x%04x' $_ms $(( RANDOM & 0xfff )) \
    $(( 8 + (RANDOM & 3) )) $(( RANDOM & 0xfff )) $RANDOM $RANDOM $RANDOM
  export ATUIN_SESSION ATUIN_SHLVL=$SHLVL
  unset _ms
fi
_cached_source atuin   atuin init zsh --disable-up-arrow  # Ctrl-R: atuin history search (after fzf, so it wins)
_cached_source direnv  direnv hook zsh                 # per-project .envrc
_cached_source mise    mise activate zsh               # runtime versions (if you use mise)

_cached_completion kubectl kubectl completion zsh
_cached_completion helm    helm completion zsh
_cached_completion gh      gh completion -s zsh
_cached_completion uv      uv generate-shell-completion zsh
_cached_completion k9s     k9s completion zsh
_cached_completion kind    kind completion zsh

# terraform ships bash-style completion only
if (( $+commands[terraform] )); then
  autoload -Uz bashcompinit && bashcompinit
  complete -o nospace -C "$commands[terraform]" terraform
fi
