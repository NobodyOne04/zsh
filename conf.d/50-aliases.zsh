# Aliases. Each one is defined only if its tool is installed.
#
# Removed on purpose:
#   grep='rg'  -> `grep -r pat .` silently became ripgrep's --replace
#   find='fd'  -> different flags; scripts and muscle memory break
#   man='tldr' -> real man pages were unreachable
# rg, fd and tldr are short enough to type; `tl` is tldr.

(( $+commands[eza] )) && {
  alias ls='eza -lah --icons=auto --group-directories-first'    # as before
  alias l='eza -1 --icons=auto --group-directories-first'
  alias ll='eza -lah --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
}
(( $+commands[lazygit] )) && alias g='lazygit'                  # re-applied after the git plugin
(( $+commands[btop] ))    && alias htop='btop'
(( $+commands[tldr] ))    && alias tl='tldr'
(( $+commands[bat] ))     && alias b='bat'
(( $+commands[nvim] ))    && alias v='nvim' vi='nvim'

alias ..='cd ..' ...='cd ../..' ....='cd ../../..'
alias -- -='cd -'
alias reload='exec zsh'
alias path='print -l $path'
alias mkdir='mkdir -p'
alias df='df -h' du='du -h'
alias please='sudo $(fc -ln -1)'          # rerun the last command with sudo
alias h='history 1 | tail -n 30'
