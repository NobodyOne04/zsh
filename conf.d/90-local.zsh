# Machine-specific settings and credentials, kept out of git:
#   ~/.config/zsh/local.zsh    anything for this machine only
#   ~/.config/zsh/secrets.zsh  API keys and tokens (chmod 600; use `secret-add NAME`)
for _f in "$XDG_CONFIG_HOME"/zsh/{local,secrets}.zsh(N); do
  source "$_f"
done
unset _f
