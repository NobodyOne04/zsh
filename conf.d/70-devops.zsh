# Docker, Kubernetes, Terraform, Helm, AWS. Plain aliases and small fzf
# helpers; nothing runs at startup.

# ---------- docker ----------
if (( $+commands[docker] )); then
  alias d='docker'
  alias dc='docker compose'
  alias dcu='docker compose up -d' dcd='docker compose down' dcl='docker compose logs -f --tail=100'
  alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
  alias dprune='docker system prune'                  # asks first; keeps volumes (database data)
  alias dprune-all='docker system prune --volumes'    # also every unused volume; asks first

  _dpick() { docker ps ${1:+$1} --format '{{.Names}}\t{{.Image}}\t{{.Status}}' | fzf --with-nth=1.. --delimiter='\t' | cut -f1 }
  # dex: shell into a running container (picked with fzf)
  dex()  { local c=${1:-$(_dpick)}; [[ -n $c ]] && docker exec -it "$c" sh -c 'command -v bash >/dev/null && exec bash || exec sh' }
  # dlog: follow a container's logs
  dlog() { local c=${1:-$(_dpick)}; [[ -n $c ]] && docker logs -f --tail=200 "$c" }
  # dstop: stop containers (multi-select with Tab)
  dstop() { docker ps --format '{{.Names}}' | fzf -m | xargs -r docker stop }
fi

# ---------- kubernetes ----------
if (( $+commands[kubectl] )); then
  alias k='kubectl'
  compdef k=kubectl 2>/dev/null
  alias kg='kubectl get' kd='kubectl describe' kdel='kubectl delete'
  alias kgp='kubectl get pods' kgpa='kubectl get pods -A' kgs='kubectl get svc' kgd='kubectl get deploy'
  alias kgn='kubectl get nodes -o wide' kge='kubectl get events --sort-by=.lastTimestamp'
  alias kaf='kubectl apply -f' kdf='kubectl delete -f'
  alias ktop='kubectl top pods --sort-by=memory'

  # kx: switch context; kn: switch namespace (fzf)
  kx() { local c=${1:-$(kubectl config get-contexts -o name | fzf --header="context: $(kubectl config current-context 2>/dev/null)")}; [[ -n $c ]] && kubectl config use-context "$c" }
  kn() { local n=${1:-$(kubectl get ns -o name | sed 's|namespace/||' | fzf --header='namespace')}; [[ -n $n ]] && kubectl config set-context --current --namespace="$n" >/dev/null && print -P "%F{cyan}›%f namespace $n" }

  _kpod() { kubectl get pods --no-headers -o custom-columns=:metadata.name,:status.phase "$@" | fzf --preview 'kubectl describe pod {1} | head -60' | awk '{print $1}' }
  # kl: follow logs; kex: shell into a pod; kpf: port-forward (kpf 8080:80)
  kl()  { local p=$(_kpod); [[ -n $p ]] && kubectl logs -f --tail=200 "$p" --all-containers }
  kex() { local p=$(_kpod); [[ -n $p ]] && kubectl exec -it "$p" -- sh -c 'command -v bash >/dev/null && exec bash || exec sh' }
  kpf() { local p=$(_kpod); [[ -n $p ]] && kubectl port-forward "$p" "${1:?usage: kpf LOCAL:REMOTE}" }
  # kdebug: throwaway pod with network tools in the current namespace
  kdebug() { kubectl run "debug-$RANDOM" --rm -it --restart=Never --image=nicolaka/netshoot -- bash }
fi

# ---------- terraform ----------
if (( $+commands[terraform] )); then
  alias tf='terraform'
  alias tfi='terraform init' tfp='terraform plan' tfa='terraform apply' tfv='terraform validate'
  alias tff='terraform fmt -recursive' tfo='terraform output'
  tfw() { local w=${1:-$(terraform workspace list | sed 's/^[* ]*//' | grep . | fzf)}; [[ -n $w ]] && terraform workspace select "$w" }
fi

# ---------- aws ----------
if (( $+commands[aws] )); then
  # awsp: pick a profile from ~/.aws/config; awswho: who am I
  awsp() {
    local p=${1:-$(sed -n 's/^\[profile \(.*\)\]$/\1/p; s/^\[default\]$/default/p' ~/.aws/config 2>/dev/null | fzf --header="aws profile: ${AWS_PROFILE:-default}")}
    [[ -n $p ]] && export AWS_PROFILE=$p && print -P "%F{cyan}›%f AWS_PROFILE=$p"
  }
  alias awswho='aws sts get-caller-identity --output table'
fi
