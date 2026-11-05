# Git helpers, loaded right after oh-my-zsh's git aliases (gst, gco, gp, gl, …).

(( $+commands[lazygit] )) && alias g='lazygit'     # the git plugin sets g=git; keep yours

# Function names must not collide with oh-my-zsh aliases: an alias with the
# same name is expanded inside `name() {` and breaks parsing (this is what
# happened with OMZ's `gclean`). `function name {` is immune; the unalias
# keeps the functions callable.
unalias gbf glf gbclean 2>/dev/null

# gbf: fuzzy-pick a branch (local or remote) and switch to it
function gbf {
  local b
  b=$(git branch --all --sort=-committerdate --format='%(refname:short)' |
      grep -v HEAD | fzf --preview 'git log --oneline --color=always -20 {}') || return
  git switch "${b#origin/}" 2>/dev/null || git switch --track "$b"
}

# glf: browse the log, preview each commit with delta, Enter shows it
function glf {
  git log --color=always --format='%C(cyan)%h%C(reset) %s %C(240)%cr · %an%C(reset)' "$@" |
    fzf --ansi --no-sort --preview 'git show --color=always {1} | delta 2>/dev/null || git show --color=always {1}' \
        --bind 'enter:execute(git show --color=always {1} | less -R)'
}

# gbclean: delete local branches already merged into the default branch
# (oh-my-zsh's own `gclean` = git clean --interactive -d is left as is)
function gbclean {
  local main=$(git_main_branch)
  git fetch -p -q
  git branch --merged "$main" | grep -vE "^\*|^\s*(main|master|develop)\s*$" | xargs -r git branch -d
}

# gwip / gunwip: park and restore unfinished work
alias gwip='git add -A && git commit -qm "WIP [skip ci]" --no-verify && echo parked'
alias gunwip='git log -1 --format=%s | grep -q "^WIP" && git reset -q HEAD~1 && echo restored'

# groot: cd to the repository root
alias groot='cd "$(git rev-parse --show-toplevel)"'
