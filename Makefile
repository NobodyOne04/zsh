# zsh config — run `make help`.

SHELL   := /bin/bash
.DEFAULT_GOAL := help

ZSHRC   := $(HOME)/.zshrc
STAMP   := $(shell date +%Y%m%d-%H%M%S)
CACHE   := $(or $(XDG_CACHE_HOME),$(HOME)/.cache)/zsh
SECRETS := $(or $(XDG_CONFIG_HOME),$(HOME)/.config)/zsh/secrets.zsh

.PHONY: help install deps devops link unlink secrets chsh update check bench clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-8s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: deps link ## Packages + link (then open a new terminal)

deps: ## Install shell tools (fzf, zoxide, eza, fd, rg, bat, direnv, lazygit, delta…)
	@./scripts/install-deps.sh

devops: ## Install devops tools too (kubectl, helm, k9s, terraform, aws, docker, yq)
	@./scripts/install-deps.sh --devops

link: ## Link ~/.zshrc to this repo; old file backed up, its secrets moved out
	@if [ -L "$(ZSHRC)" ] && [ "$$(readlink "$(ZSHRC)")" = "$(CURDIR)/zshrc" ]; then \
		echo "already linked: $(ZSHRC)"; \
	else \
		if [ -e "$(ZSHRC)" ] || [ -L "$(ZSHRC)" ]; then \
			mv "$(ZSHRC)" "$(ZSHRC).bak-$(STAMP)"; echo "backed up: $(ZSHRC) -> $(ZSHRC).bak-$(STAMP)"; \
			./scripts/migrate-secrets.sh "$(ZSHRC).bak-$(STAMP)"; \
		fi; \
		ln -s "$(CURDIR)/zshrc" "$(ZSHRC)"; echo "linked: $(ZSHRC) -> $(CURDIR)/zshrc"; \
	fi

unlink: ## Restore the most recent ~/.zshrc backup
	@if [ -L "$(ZSHRC)" ] && [ "$$(readlink "$(ZSHRC)")" = "$(CURDIR)/zshrc" ]; then \
		rm "$(ZSHRC)"; last=$$(ls -d $(ZSHRC).bak-* 2>/dev/null | sort | tail -1); \
		if [ -n "$$last" ]; then mv "$$last" "$(ZSHRC)"; echo "restored $$last"; else echo "removed link (no backup found)"; fi; \
	else echo "$(ZSHRC) is not linked to this repo"; fi

secrets: ## Move credentials from FILE=<old zshrc> into $(SECRETS)
	@./scripts/migrate-secrets.sh "$(or $(FILE),$(error usage: make secrets FILE=path))"

chsh: ## Make zsh the login shell (Arch defaults to bash)
	chsh -s "$$(command -v zsh)"

update: ## Update zinit and all plugins, then rebuild caches
	zsh -i -c 'zinit self-update && zinit update --all --parallel --quiet'
	@$(MAKE) --no-print-directory clean

check: ## Syntax-check every file and make sure startup prints nothing
	@for f in zshrc p10k.zsh conf.d/*.zsh lib/*.zsh; do zsh -n "$$f" || exit 1; done; echo "ok: syntax"
	@log=$$(mktemp); \
	if [ "$$(uname)" = Darwin ]; then script -q "$$log" zsh -i -c 'print -r -- CHECK_DONE' >/dev/null 2>&1; \
	else script -qec "zsh -i -c 'print -r -- CHECK_DONE'" "$$log" >/dev/null 2>&1; fi; \
	all=$$(tr -d '\r\004' < "$$log" | sed -e '/^Script \(started\|done\)/d' -e '/^[[:space:]]*$$/d'); rm -f "$$log"; \
	if ! printf '%s\n' "$$all" | grep -q CHECK_DONE; then echo "could not start an interactive zsh (run this from a terminal)"; exit 1; fi; \
	out=$$(printf '%s\n' "$$all" | grep -v CHECK_DONE); \
	if [ -n "$$out" ]; then echo "startup printed:"; echo "$$out"; exit 1; else echo "ok: silent startup"; fi

bench: ## Time 10 interactive startups
	@zsh -c 'zmodload zsh/datetime; repeat 10 { s=$$EPOCHREALTIME; zsh -i -c exit >/dev/null 2>&1; printf "  %.0f ms\n" $$(( (EPOCHREALTIME - s) * 1000 )) }'

clean: ## Drop generated caches (tool inits, completions, compdump); rebuilt on next start
	rm -rf "$(CACHE)"
