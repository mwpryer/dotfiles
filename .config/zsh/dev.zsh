# git
alias g="git"
alias lg="lazygit"
export LG_CONFIG_FILE="${HOME}/.config/lazygit/config.yml"

# github
alias ghpr="gh pr view --web"
alias ghprc="gh pr create --web"
alias ghprl="gh pr list"
alias ghprs="gh pr status"
alias ghr="gh repo view --web"
alias ghi="gh issue list"

# docker
alias dk="docker"
alias dkc="docker compose"
alias dkp="docker ps"
alias dkpa="docker ps -a"
alias dkl="docker logs -f"
alias dkx="docker exec -it"
alias dki="docker images"
alias dkr="docker run --rm -it"
alias dks="docker stop"
alias dkrm="docker rm"
alias ldk="lazydocker"
# fuzzy docker logs
dklf() {
  local cid="$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | fzf --header="Select container for logs" | awk '{print $1}')"
  [[ -n "${cid}" ]] && docker logs -f "${cid}"
}
# fuzzy docker exec
dkxf() {
  local cid="$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | fzf --header="Select container to exec into" | awk '{print $1}')"
  [[ -n "${cid}" ]] && docker exec -it "${cid}" "${1:-sh}"
}

# terraform
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfd="terraform destroy"
alias tff="terraform fmt -recursive"

# vscode
code-sync() {
  local extfile="${HOME}/.config/code/extensions.txt"
  local installed="$(code --list-extensions)"
  local wanted="$(<"${extfile}")"
  # install missing
  comm -23 <(echo "${wanted}" | sort) <(echo "${installed}" | sort) | xargs -rn1 code --install-extension
  # uninstall removed
  comm -13 <(echo "${wanted}" | sort) <(echo "${installed}" | sort) | xargs -rn1 code --uninstall-extension
  # update list
  code --list-extensions >"${extfile}"
}
alias code-export="code --list-extensions >${HOME}/.config/code/extensions.txt"

# neovim
alias v="nvim"

# development
alias ns="nr"
alias nd="nr dev"
alias nb="nr build"
alias nf="nr format"
alias nt="nr test"
alias py="python3"
alias serve="python3 -m http.server"
# list listening ports
alias ports="lsof -iTCP -sTCP:LISTEN -P -n"
# kill process by name
k() {
  pkill -f "$1" && echo "Killed $1" || echo "No process found matching $1"
}
# fuzzy-find and kill processes
kf() {
  local pid
  pid="$(ps -u "${USER}" -ww -o pid,%cpu,%mem,start,args | fzf -m --header-lines=1 | awk '{print $1}')"
  [[ -n "${pid}" ]] && echo "${pid}" | xargs kill -"${1:-9}"
}
# kill process by port
kp() {
  lsof -ti:"$1" | xargs kill 2>/dev/null || echo "No process found on port $1"
}
# fuzzy-find and kill processes by port
kpf() {
  local pid
  pid="$(lsof -iTCP -sTCP:LISTEN -P -n | fzf -m --header-lines=1 | awk '{print $2}')"
  [[ -n "${pid}" ]] && echo "${pid}" | xargs kill -"${1:-9}"
}

# mise
eval "$(mise activate zsh)"

# bun
eval "$(bun completions)"

# uv
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# gcloud
safe_source "${HOME}/google-cloud-sdk/path.zsh.inc"
safe_source "${HOME}/google-cloud-sdk/completion.zsh.inc"
alias gc="gcloud"
# append to a gcloud command to format output
alias -g :j='--format=json | jq -C | less -RFX'
alias -g :y='--format=yaml | bat -l yaml --style=plain --paging=auto'
# curl any gcp api with auto-injected bearer token
gcurl() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" "$@"
}
# auth
alias gcal="gcloud auth login"
alias gcad="gcloud auth application-default login"
# switch gcloud account with fzf
gcaf() {
  local account="$(gcloud auth list --format="value(account)" | fzf)"
  if [[ -n "${account}" ]]; then
    gcloud config set account "${account}"
    gcpe
  fi
}
# revoke gcloud accounts with fzf multi-select (tab to mark)
gcarf() {
  local accounts="$(gcloud auth list --format="value(account)" | fzf -m --header="tab to select, enter to revoke")"
  [[ -n "${accounts}" ]] && echo "${accounts}" | xargs gcloud auth revoke
}
# project
# export current gcloud project as env vars
gcpe() {
  local project_id="$(gcloud config get core/project 2>/dev/null)"
  local project_number="$(gcloud projects describe "${project_id}" --format="value(projectNumber)" 2>/dev/null)"
  if [[ -n "${project_id}" ]] && [[ -n "${project_number}" ]]; then
    export GC_PROJECT_ID="${project_id}"
    export GC_PROJECT_NUMBER="${project_number}"
  else
    unset GC_PROJECT_ID
    unset GC_PROJECT_NUMBER
  fi
}
# switch gcloud project with fzf
gcpf() {
  local project_id="$(gcloud projects list --format="value(projectId)" | fzf)"
  if [[ -n "${project_id}" ]]; then
    gcloud config set project "${project_id}"
    gcpe
  fi
}
# switch gcloud configuration with fzf (bundle of account + project + defaults)
gccf() {
  local config="$(gcloud config configurations list --format="value(name)" | fzf)"
  if [[ -n "${config}" ]]; then
    gcloud config configurations activate "${config}"
    gcpe
  fi
}
# cloud run
# proxy a cloud run service to localhost, optional port
gcrpf() {
  local service region
  read -r service region <<<"$(gcloud run services list --format='value(metadata.name,metadata.labels."cloud.googleapis.com/location")' | fzf)"
  [[ -n "${service}" ]] && gcloud run services proxy "${service}" --region "${region}" --port "${1:-8080}"
}
# read recent cloud run service logs
gcrlf() {
  local service region
  read -r service region <<<"$(gcloud run services list --format='value(metadata.name,metadata.labels."cloud.googleapis.com/location")' | fzf)"
  [[ -n "${service}" ]] && gcloud run services logs read "${service}" --region "${region}"
}
# secrets
# print latest secret version
gcsf() {
  local secret="$(gcloud secrets list --format="value(name)" | fzf)"
  [[ -n "${secret}" ]] && gcloud secrets versions access latest --secret="${secret}"
}

# claude code
alias cld="claude --dangerously-skip-permissions"
alias cldr="claude --dangerously-skip-permissions --resume"
alias cldf="claude --dangerously-skip-permissions --model fable"
alias cldo="claude --dangerously-skip-permissions --model opus"
alias clds="claude --dangerously-skip-permissions --model sonnet"
alias cldp="claude -p"

# codex
alias cdx="codex --dangerously-bypass-approvals-and-sandbox"
alias cdxr="codex resume --dangerously-bypass-approvals-and-sandbox"
alias cdxp="codex exec"

# opencode
alias oc="opencode --auto"
alias ocr="opencode --auto -c"
alias ocp="opencode run --auto"
