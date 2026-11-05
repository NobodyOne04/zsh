# Shell behaviour, history, key bindings.

# history (file location unchanged so nothing is lost)
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY        # timestamps
setopt SHARE_HISTORY           # all terminals share history
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt HIST_IGNORE_SPACE       # a leading space keeps a command (and any secret in it) out of history
setopt HIST_EXPIRE_DUPS_FIRST

# navigation & globbing
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt EXTENDED_GLOB GLOB_DOTS NO_CASE_GLOB
setopt INTERACTIVE_COMMENTS    # allow # comments at the prompt
setopt NO_BEEP NO_FLOW_CONTROL # Ctrl-S/Ctrl-Q free for bindings
unsetopt CORRECT CORRECT_ALL   # the old "did you mean" prompts (ENABLE_CORRECTION) are gone

# keys: emacs style, plus the usual extras
bindkey -e
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey '^X^E' edit-command-line          # edit the command in $EDITOR
bindkey '^[[1;5C' forward-word            # Ctrl-Right
bindkey '^[[1;5D' backward-word           # Ctrl-Left
bindkey '^[[H' beginning-of-line '^[[F' end-of-line
bindkey '^[[3~' delete-char
WORDCHARS=${WORDCHARS//[\/.-]}            # Ctrl-W stops at / . -
