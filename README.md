# zsh

Fast, quiet zsh for development and devops, styled like the archminimal desktop (one cyan accent, no
backgrounds). Works on Arch Linux and macOS.

- **~150 ms** to a ready shell, down from ~2,900 ms; the prompt appears instantly (Powerlevel10k instant prompt).
- One plugin manager (zinit); everything not needed for the prompt loads right after it ("turbo").
- No secrets in this repo: credentials live in `~/.config/zsh/secrets.zsh` (mode 600, git-ignored).

## Install

```bash
git clone git@github.com:NobodyOne04/zsh.git ~/projects/zsh && cd ~/projects/zsh
make install     # shell tools + link ~/.zshrc (old file backed up, secrets moved out)
make devops      # optional: kubectl, helm, k9s, terraform, aws, docker, yq
make chsh        # Arch: make zsh your login shell
```

Open a new terminal. The first start downloads zinit and the plugins; after that it is instant.
A Nerd Font is needed for icons (`ttf-jetbrains-mono-nerd`; the hyprland repo installs it).

`make link` moves your current `~/.zshrc` to `~/.zshrc.bak-<date>` and copies any `export …KEY/TOKEN/SECRET/PASSWORD=`
lines from it into `~/.config/zsh/secrets.zsh` (names are printed, values never). `make unlink` restores the
backup.

## Layout

```text
zshrc                    entry point (~/.zshrc links here): instant prompt, then conf.d/*
p10k.zsh                 prompt
conf.d/00-env.zsh        XDG dirs, editor, PATH (deduplicated), fzf colors
conf.d/10-options.zsh    history, navigation, key bindings
conf.d/20-plugins.zsh    zinit + plugins
conf.d/30-completion.zsh compinit (cached daily) + fzf-tab
conf.d/40-tools.zsh      zoxide, fzf, direnv, mise; cached completions (kubectl, helm, gh, uv, …)
conf.d/50-aliases.zsh    aliases
conf.d/60-functions.zsh  general helpers
conf.d/70-devops.zsh     docker, kubernetes, terraform, aws
conf.d/90-local.zsh      loads ~/.config/zsh/local.zsh and secrets.zsh
lib/git.zsh              git helpers (loaded after oh-my-zsh's git aliases)
```

## Prompt

```text
~/projects/zsh main ✱                              ✘ 1  4s  venv  14:02
❯
```

Directory and git on the left; on the right only what matters: last exit code if it failed, duration if over
3 s, background jobs, direnv, Python venv, time. The **kubernetes context**, **AWS profile** and **terraform
workspace** appear only while you type a command that uses them (`k`, `kubectl`, `helm`, `aws`, `tf`…), so
you always see which cluster you are about to touch. Old prompts collapse to a single `❯` line.

## Keys

| Keys | Action |
|---|---|
| `↑` / `↓` | history search for what you have typed so far |
| `Ctrl-R` | fuzzy history |
| `Ctrl-T` / `Alt-C` | fuzzy-insert a file / cd into a directory (with previews) |
| `Tab` | completion menu with fuzzy filter and previews (fzf-tab); `<` `>` switch groups |
| `→` | accept the grey suggestion |
| `Ctrl-X Ctrl-E` | edit the command in nvim |
| `z <dir>` / `zi` | jump to a frequent directory / pick one |
| space before a command | keeps it out of history (use it for anything with a secret) |

## Aliases and helpers

**Everyday:** `ls` `ll` `lt` (eza), `g` (lazygit), `v` (nvim), `b` (bat), `tl` (tldr), `htop` (btop), `..` `...`,
`-` (previous dir), `reload`, `path`, `please` (rerun last command with sudo).

| Helper | Does |
|---|---|
| `mkcd dir` | create and enter |
| `extract file` | unpack any archive |
| `clip` / `clip -o` | copy from a pipe / paste (macOS and Wayland) |
| `port 8080` / `ports` | what listens on a port / all listening ports |
| `serve [port]` | serve the current directory over HTTP |
| `json [file]` | pretty-print JSON (also from a pipe) |
| `b64e` `b64d` `uuid` `myip` `cheat topic` | small utilities |
| `venv` | create (with uv if present) and activate `./.venv` |
| `secret-add NAME` | store a credential in the secrets file (hidden input, never in history) |
| `zbench` | measure startup |
| `fix-history` | repair "zsh: corrupt history file" (keeps everything readable, saves the damaged copy) |

**Git** (on top of oh-my-zsh's git aliases: `gst`, `gco`, `gp`, `gl`, `gcmsg`, …):
`gbf` fuzzy branch switch, `glf` browse the log with diffs, `gbclean` delete merged branches, `gwip` / `gunwip`
park work, `groot` cd to the repo root.

**Docker:** `d`, `dc` (compose), `dcu` `dcd` `dcl`, `dps` (tidy table), `dex` (fuzzy-pick a container and get a
shell), `dlog` (follow logs), `dstop` (multi-select stop), `dprune`.

**Kubernetes:** `k` (with completion), `kg` `kd` `kgp` `kgpa` `kgs` `kgd` `kgn` `kge` `kaf` `kdf` `ktop`;
`kx` switch context and `kn` switch namespace (fuzzy); `kl` follow pod logs, `kex` shell into a pod,
`kpf 8080:80` port-forward (pods picked with a `describe` preview); `kdebug` starts a throwaway netshoot pod.

**Terraform:** `tf` `tfi` `tfp` `tfa` `tfv` `tff` `tfo`, `tfw` (fuzzy workspace switch).
**AWS:** `awsp` (fuzzy profile switch), `awswho`.

Every helper is defined only when its tool is installed.

## Secrets and per-machine settings

- `~/.config/zsh/secrets.zsh`: API keys and tokens. Add with `secret-add OPENAI_API_KEY`.
- `~/.config/zsh/local.zsh`: anything for one machine only (see `local.zsh.example`).

Both are loaded last and are never part of this repo.

## Makefile

| Target | What |
|---|---|
| `make install` | `deps` + `link` |
| `make deps` / `devops` | shell tools / devops tools (pacman or brew) |
| `make link` / `unlink` | link `~/.zshrc` (backup + secret migration) / restore the backup |
| `make secrets FILE=…` | move credentials from any old file into the secrets file |
| `make chsh` | zsh as login shell |
| `make update` | update zinit and plugins, rebuild caches |
| `make check` | syntax-check everything and fail if startup prints anything |
| `make bench` | time 10 startups |
| `make clean` | drop generated caches (rebuilt automatically) |

## What changed

The old `.zshrc` (3,334 lines, 158 KB) had:

- **A line that appended to `~/.zshrc` on every shell start**
  (`echo 'export PATH=…libpq…' >> ~/.zshrc`): 3,182 copies, `PATH` with 3,249 entries (21 unique), and a
  slower shell every time a terminal opened. PATH is now deduplicated by zsh itself.
- **An OpenAI API key in plain text**, committed to this repo. It is gone from the files, but it remains in
  git history: **revoke it and create a new one**, then store the new one with `secret-add`.
- **Two plugin managers** (oh-my-zsh and zinit) loading powerlevel10k and autosuggestions twice, **two syntax
  highlighters**, `direnv` and `fzf` hooked twice, and `$(go env GOPATH)` starting Go on every launch.
- **Aliases that changed meaning:** `grep='rg'` (`grep -r` became ripgrep's *replace*), `find='fd'`,
  `man='tldr'` (real man pages unreachable). Removed; use `rg`, `fd`, `tl` directly.
- Smaller: a PATH entry pointing at a file, the obsolete `reattach-to-user-namespace` tmux wrapper,
  `ENABLE_CORRECTION` prompts, the `virtualenvwrapper` plugin.
