# One plugin manager: zinit (oh-my-zsh is gone; the bits you used are loaded
# as zinit snippets). Plugins that are not needed to draw the prompt load
# "turbo": right after the prompt appears.

typeset -gA ZINIT
ZINIT[HOME_DIR]=$XDG_DATA_HOME/zinit
ZINIT[BIN_DIR]=$ZINIT[HOME_DIR]/zinit.git
ZINIT[ZCOMPDUMP_PATH]=$ZSH_CACHE_DIR/zcompdump
if [[ ! -f $ZINIT[BIN_DIR]/zinit.zsh ]]; then
  print -P "%F{cyan}› installing zinit…%f"
  command git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT[BIN_DIR]"
fi
source "$ZINIT[BIN_DIR]/zinit.zsh"

# prompt (must load now)
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f $ZSH_CONFIG_DIR/p10k.zsh ]] && source "$ZSH_CONFIG_DIR/p10k.zsh"

# extra completion definitions: only adds to fpath, before compinit
zinit ice blockf
zinit light zsh-users/zsh-completions

# after the prompt: suggestions, highlighting, history search, git aliases
zinit wait lucid light-mode for \
    atload'_zsh_autosuggest_start' \
  zsh-users/zsh-autosuggestions \
    atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down;
           bindkey "^P" history-substring-search-up; bindkey "^N" history-substring-search-down' \
  zsh-users/zsh-history-substring-search \
  zdharma-continuum/fast-syntax-highlighting

# oh-my-zsh's git aliases (gst, gco, gp, …) + our git helpers on top
zinit wait lucid for \
  OMZL::git.zsh \
    atload'source "$ZSH_CONFIG_DIR/lib/git.zsh"' \
  OMZP::git

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#4a4c54'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#00e5ff,bold'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
