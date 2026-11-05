# ┌──────────────────────────────────────────────────────────────┐
# │ zsh · archminimal                                             │
# │ ~/.zshrc → this file. Everything else lives next to it.       │
# │ Startup budget: ~50 ms to a usable prompt.                    │
# └──────────────────────────────────────────────────────────────┘

# Powerlevel10k instant prompt: draws the prompt immediately while the rest
# loads. Anything that prints or asks for input must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Directory of this repo, following the ~/.zshrc symlink.
typeset -g ZSH_CONFIG_DIR=${${(%):-%x}:A:h}

for _f in "$ZSH_CONFIG_DIR"/conf.d/*.zsh(N); do
  source "$_f"
done
unset _f
