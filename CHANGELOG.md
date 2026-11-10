# Changelog

## Unreleased

### Added
- CI runs `make lint` (syntax of every file) on every PR
- `CLAUDE.md`: how to work on this repo with Claude Code

### Fixed
- `gwip` no longer skips the gitleaks secret scan
- `dprune` asks before pruning and keeps volumes; `dprune-all` is the full wipe, also asking
- `gbclean` also offers to delete branches that were squash-merged on GitHub

### Changed
- atuin's session id is made in zsh instead of running `atuin uuid` on every start (~10 ms faster)

### Removed
- `clip`: same as `cbc` / `cbp`, which also cover X11
