# zsh

Fast, quiet zsh for development and devops, styled like the archminimal desktop (one cyan accent, no
backgrounds). Works on Arch Linux and macOS.

- **~150 ms** to a ready shell, down from ~2,900 ms; the prompt appears instantly (Powerlevel10k instant prompt).
- One plugin manager (zinit); everything not needed for the prompt loads right after it ("turbo").
- No secrets in this repo: credentials live in `~/.config/zsh/secrets.zsh` (mode 600, git-ignored).
- Also the rest of the terminal setup, linked by `make link`: git (delta, global gitleaks hook, signing),
  direnv (`layout project`), atuin and lazygit. Same files on the Mac and on Arch. (tmux has its own repo.)

## Install

```bash
git clone git@github.com:NobodyOne04/zsh.git ~/projects/zsh && cd ~/projects/zsh
make install     # shell tools + link ~/.zshrc and the other configs (old files backed up, secrets moved out)
make age-key     # once: your key for encrypted .env.sops files (back it up!)
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
git/config               -> ~/.config/git/config   shared git settings (identity stays in ~/.gitconfig)
git/ignore               -> ~/.config/git/ignore   ignored in every repo (.env, .envrc, .DS_Store…)
git/hooks/               -> ~/.config/git/hooks    global hooks: gitleaks, then the repo's own hook
direnv/direnvrc          -> ~/.config/direnv/direnvrc   `layout project`, `dotenv_sops`
atuin/config.toml        -> ~/.config/atuin/config.toml
lazygit/config.yml       -> ~/.config/lazygit/config.yml
scripts/link.sh          creates / removes / checks all the links above
```

## Prompt

The same look as on the Mac: Powerlevel10k "classic", two lines, slanted segments, a frame on the right.

```text
  ~/projects/zsh  on  main !1 ─────────────────────── took 4s  at 14:02:07  ─╮
❯                                                                                  ─╯
```

- **Left:** the OS logo (the Arch logo in cyan on Arch, the Apple logo on macOS), the directory, and git:
  branch, `⇣⇡` behind/ahead, `+` staged, `!` unstaged, `?` untracked, `*` stashes, `~` conflicts.
- **Right:** duration of commands over 3 s, background jobs, direnv, Python venv, time. A red `❯` means the
  last command failed.
- The **kubernetes context**, **AWS profile** and **terraform workspace** appear only while you type a command
  that uses them (`k`, `kubectl`, `helm`, `aws`, `tf`…), so you always see which cluster you are about to touch.
- Old prompts collapse to a single `❯` line. `p10k configure` builds another style (it writes `~/.p10k.zsh`;
  copy that over `p10k.zsh` here to keep it).

## Keys

| Keys | Action |
|---|---|
| `↑` / `↓` | history search for what you have typed so far |
| `Ctrl-R` | history search (atuin; `Ctrl-R` again switches all / this host / this session / this dir) |
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
| `envinit` | give a project a one-line `.envrc` (`layout project`) and allow it |
| `env-encrypt` / `env-edit` | encrypt `.env` into `.env.sops` (committable) / edit it decrypted |
| `leaks` | scan this repo's history and files for secrets |
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

## Per-project environment (direnv)

`cd` into a project and its environment loads; leave and it is unloaded. A project's `.envrc` is one line,
`layout project` (run `envinit`), defined in `direnv/direnvrc`:

- `.env`: plain variables. Git-ignored in every repo by `git/ignore`.
- `.env.sops`: the same, encrypted with your age key, so it **can** be committed. `env-encrypt` creates it,
  `env-edit` changes it; it is decrypted in memory only. The key is `~/.config/sops/age/keys.txt` on both
  systems (`make age-key`); keep a copy in your password manager and copy it to each machine.
- `.venv/` or `venv/`: activated.

After editing a `.envrc`, run `direnv allow` once.

## Git

`git/config` is shared by every machine: delta for diffs, `pull.rebase`, `push.autoSetupRemote`, `rerere`,
`zdiff3` conflicts, `main` for new repos. Per machine, in `~/.gitconfig`: `user.name`, `user.email`, and signing:

```bash
git config --global user.signingkey ~/.ssh/id_ed25519.pub   # your key on this machine
git config --global commit.gpgSign true
echo "$(git config user.email) $(cut -d' ' -f1,2 ~/.ssh/id_ed25519.pub)" >> ~/.config/git/allowed_signers
```

Add the same public key on GitHub as a **Signing Key** to get "Verified" commits.

**Secret scanning:** every `git commit` in every repo runs `gitleaks` on the staged changes and stops if it finds a
key or token. False positive: put `gitleaks:allow` in a comment on that line (or list the finding in the repo's
`.gitleaksignore`); skip once with `SKIP_GITLEAKS=1 git commit …`. After the check, the repo's own
`.git/hooks/<name>` still runs. The pre-commit framework refuses to install while a global hooks path is set; in
such a repo run `git config --local core.hooksPath .git/hooks && pre-commit install` (that repo then skips the
global gitleaks hook, so add gitleaks to its `.pre-commit-config.yaml`).

## Makefile

| Target | What |
|---|---|
| `make install` | `deps` + `link` |
| `make deps` / `devops` | shell tools / devops tools (pacman or brew) |
| `make link` / `unlink` | link all configs (backups + secret migration) / restore the backups |
| `make status` | which configs are linked |
| `make age-key` | create your age key for `.env.sops` (once) |
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
