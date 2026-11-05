# Completion: compinit once a day (otherwise the cached dump is trusted),
# then fzf-tab for a searchable, previewed completion menu.

autoload -Uz compinit
_zcomp=$ZINIT[ZCOMPDUMP_PATH]
if [[ -n $_zcomp(#qN.mh+24) || ! -f $_zcomp ]]; then
  compinit -i -d "$_zcomp"
  { zcompile "$_zcomp" } &!
else
  compinit -C -d "$_zcomp"
fi
unset _zcomp
zinit cdreplay -q   # replay compdefs queued by plugins

zstyle ':completion:*' menu no                                  # fzf-tab draws the menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/compcache"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false

zinit light Aloxaf/fzf-tab
zstyle ':fzf-tab:*' fzf-flags '--height=50%' '--border=rounded' '--color=hl:#00e5ff,hl+:#00e5ff,pointer:#00e5ff,border:#3a3c44'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
zstyle ':fzf-tab:complete:(nvim|vim|bat|cat|less):*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -o pid,%cpu,%mem,command -p $word'
