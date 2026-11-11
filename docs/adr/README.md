# Architecture Decision Records

Why this config is built the way it is. Files are `NNNN-title.adr` (Markdown).

| # | Decision | Status |
|---|---|---|
| [0001](0001-conf-d-layout-symlinked-repo.adr) | One repo, symlinked into ~, split into numbered conf.d files | Accepted |
| [0002](0002-zinit-turbo-plugins.adr) | zinit as the only plugin manager, non-prompt plugins load turbo | Accepted |
| [0003](0003-startup-budget-cached-inits.adr) | Startup is silent and fast: no process per shell, tool inits cached | Accepted |
| [0004](0004-powerlevel10k-hand-edited.adr) | Powerlevel10k with instant prompt, `p10k.zsh` edited by hand | Accepted |
| [0005](0005-one-config-both-oses.adr) | One config for macOS and Arch, guarded per OS and per tool | Accepted |
| [0006](0006-secrets-out-of-repo-gitleaks.adr) | Secrets never in the repo: untracked secrets file, global gitleaks hook | Accepted |
| [0007](0007-direnv-layout-project-sops.adr) | Per-project env via direnv `layout project`, sops-encrypted .env | Accepted |
