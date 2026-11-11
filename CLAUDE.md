# CLAUDE.md: zsh config

My shell config for a Mac and an Arch desktop, plus the git/direnv/atuin/lazygit/eza configs that ship
with it. `~/.zshrc` is a symlink to `zshrc` here; edit this repo, never the link target or a `.bak-*`.
`README.md` is for me (keys, aliases, helpers); this file is for you.

## Map: where a change goes

| Change | File |
|---|---|
| env var, PATH, fzf/bat look | `conf.d/00-env.zsh` (spawns no processes) |
| setopt, history, key bindings | `conf.d/10-options.zsh` |
| zinit plugin | `conf.d/20-plugins.zsh` |
| completion styles, fzf-tab | `conf.d/30-completion.zsh` |
| tool init (`tool init zsh`), generated completions | `conf.d/40-tools.zsh` via `_cached_source` / `_cached_completion` |
| alias | `conf.d/50-aliases.zsh` |
| general helper function | `conf.d/60-functions.zsh` |
| docker / k8s / terraform / aws | `conf.d/70-devops.zsh` |
| git helper | `lib/git.zsh` (loaded after oh-my-zsh's git plugin) |
| prompt | `p10k.zsh`: edit by hand, never `p10k configure` (custom OS logo + colours) |
| git defaults, global ignore, global hooks | `git/config`, `git/ignore`, `git/hooks/_dispatch` (every hook is a symlink to it) |
| per-project env | `direnv/direnvrc` (`layout project`) |
| architectural decision (why it's built this way) | `docs/adr/NNNN-title.adr` + `docs/adr/README.md` index |
| new file to link into `~` | `scripts/link.sh` `links=(…)`, then tell me to run `make link` |

`zshrc` only sources `conf.d/*.zsh` in name order; `90-local` sources the untracked
`~/.config/zsh/{local,secrets}.zsh` last.

## Rules

- **Guard on the tool**: `(( $+commands[x] )) && alias …`. Every helper must work when its tool is missing.
- **Both OSes in one file**: `(( IS_MAC ))` / `[[ $OSTYPE == darwin* ]]`, then `$WAYLAND_DISPLAY`, then X11.
  macOS has BSD `sed`/`xargs`/`date`: `sed -i.bak` not `sed -i`; check flags exist on both.
- **Startup is silent and fast**: no output, no network, no process per shell (cache it in
  `40-tools.zsh` instead). Budget ~50 ms; now ~60 ms. Output before the prompt breaks p10k instant prompt.
- **Function names**: oh-my-zsh's git plugin defines hundreds of aliases (`gclean`, `gbd`, …). An alias with
  the same name breaks `name() {` at parse time. Use `function name {` and `unalias name 2>/dev/null`,
  and check first: `zsh -ic '@zinit-scheduler burst; whence -w NAME'`.
- **Never** secrets in the repo (gitleaks runs on every commit; don't `--no-verify` or `SKIP_GITLEAKS`).
- **Destructive helpers ask first** (`read -q`), never `-f` by default.
- Comment the why, one line, matching the tone around it. New/changed alias or helper: update the
  README table in the same commit.

## Test

```sh
make lint                       # zsh -n on everything + git/direnv/hooks parse (CI runs this)
make check                      # lint + interactive startup must print nothing
make bench                      # 10 startups in ms
zsh -ic 'whence -w mkcd'        # a fresh interactive shell
zsh -ic '@zinit-scheduler burst >/dev/null 2>&1; whence -w gst gbclean'   # see gotcha 1
```

## Gotchas (each cost time once)

1. **Turbo plugins aren't in `zsh -ic`.** zinit loads autosuggestions, syntax highlighting, the oh-my-zsh git
   plugin and `lib/git.zsh` *after* the first prompt, which a `-c` shell never reaches. Run
   `@zinit-scheduler burst` first, or `git_main_branch`, `gst`, `gbclean` look missing.
2. **Cached inits.** `_cached_source` writes `~/.cache/zsh/<tool>.zsh` and only regenerates it when the tool's
   binary is newer. After changing how a tool is initialised, `make clean` (or delete that one file).
3. **compinit trusts its dump for 24 h** (`compinit -C`). A new completion function or fpath entry shows up
   the next day, or after `make clean`. `_cached_completion` writes in the background, so the first shell
   after installing a tool doesn't have its completion yet.
4. **`make check` can flake once** with "could not start an interactive zsh": `script` without a real
   terminal. Run it again before suspecting the config.
5. **atuin session id** is made in `40-tools.zsh` (UUIDv7, no process). If atuin history breaks after an atuin
   upgrade, check `atuin uuid`'s format against that block first.
6. Hooks: `core.hooksPath` is global, so a repo using the pre-commit framework needs
   `git config --local core.hooksPath .git/hooks` (README explains).

## Workflow

- Changes go through the `github-flow` skill: branch, `CHANGELOG.md` line, PR (opened in the browser),
  CI must pass, I merge. Never commit or push to `main`.
- After a merge: remind me to `git pull` here and on the other machine, then `reload`;
  `make link` only if `scripts/link.sh` gained a link.
- Ask before `make install`, `make deps`, `make link`/`unlink`, `make chsh`, package installs, or
  touching `~/.oh-my-zsh`, `~/.local/share/zinit`.
