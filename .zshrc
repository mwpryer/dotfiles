export HISTFILE="${HOME}/.histfile"
export HISTSIZE=10000
export SAVEHIST=10000
export EDITOR="code"
export VISUAL="code --wait"
# gpg tty for commit signing
export GPG_TTY="$(tty)"

# source file if it exists
safe_source() {
  [[ -s "$1" ]] && source "$1"
}

# deduplicate PATH, keeping first occurrence
typeset -U PATH path

prepend_path() {
  path=("$1" $path)
}

# zsh options
setopt autocd
setopt beep
setopt extendedglob
setopt nomatch
setopt notify
# vi mode
bindkey -v
autoload -Uz compinit
compinit

# plugins
safe_source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
safe_source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# homebrew plugin paths
if command -v brew &>/dev/null; then
  safe_source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  safe_source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# prompt
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
eval "$(starship init zsh)"

# shell
alias dotfiles="${VISUAL:-${EDITOR}} -n ${HOME}/dotfiles"
alias sysfiles="${VISUAL:-${EDITOR}} -n ${HOME}/sysfiles"
alias s="source ${HOME}/.zshrc"
alias c="clear"

# navigation
# zoxide
[[ -o interactive ]] && eval "$(zoxide init --cmd cd zsh)"
# cd aliases
alias -- -="cd -"
alias ..="cd .."
alias ...="cd ../.."
alias mkd="mkdir -pv"
mkcd() {
  mkdir -p "$1" && cd "$1"
}
alias mv="mv -vi"
alias cp="cp -vi"
alias rm="rm -vI"
# eza
alias ls="eza -a --icons --group-directories-first"
alias ll="eza -lahF --icons --git --group-directories-first"
alias lt="eza --long --tree --level=3 --icons --git --group-directories-first --ignore-glob node_modules"
# bat
alias cat="bat"
# colourise help with bat
alias -g -- -h="-h 2>&1 | bat --language=help --style=plain"
alias -g -- --help="--help 2>&1 | bat --language=help --style=plain"
# bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
# fzf
eval "$(fzf --zsh)"
# catppuccin mocha theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"
# fd as fzf backend
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
# fuzzy find with bat preview
alias fzfp="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
# fuzzy find (also ctrl+t)
alias f="fzf"
# fuzzy cd (also alt+c)
cdf() { cd "$(fd --type d --hidden --follow --exclude .git | fzf)" && ls; }
# fuzzy-find file, open in editor
vf() { local file="$(fzf)" && [[ -n "${file}" ]] && "${EDITOR:-nvim}" "${file}"; }
# trash
alias trp="trash-put"
alias trl="trash-list"
alias trr="trash-restore"

# git
alias g="git"
alias lg="lazygit"
export LG_CONFIG_FILE="${HOME}/.config/lazygit/config.yml"

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

# github
alias ghpr="gh pr view --web"
alias ghprc="gh pr create --web"
alias ghprl="gh pr list"
alias ghprs="gh pr status"
alias ghr="gh repo view --web"
alias ghi="gh issue list"

# tmux
alias tm="tmux"
alias tma="tmux attach -t"
alias tmd="tmux detach"
alias tml="tmux ls"
alias tmk="tmux kill-session -t"
alias tmka="tmux kill-server"
# start session named after current dir
tmn() {
  tmux new -s "$(basename "${PWD}")"
}
# fuzzy attach to session
tmf() {
  local session="$(tmux ls -F '#{session_name}' 2>/dev/null | fzf --height 40% --layout reverse --border)"
  [[ -n "${session}" ]] && tmux attach -t "${session}"
}

# yazi
# drop into current dir on exit
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="${tmp}"
  IFS= read -r -d '' cwd < "${tmp}"
  [[ -n "${cwd}" ]] && [[ "${cwd}" != "${PWD}" ]] && builtin cd -- "${cwd}"
  rm -f -- "${tmp}"
}

# vscode
code-sync() {
  local extfile="${HOME}/.config/code/extensions.txt"
  local installed="$(code --list-extensions)"
  local wanted="$(<"${extfile}")"
  # install missing
  comm -23 <(echo "${wanted}" | sort) <(echo "${installed}" | sort) | xargs -n1 code --install-extension
  # uninstall removed
  comm -13 <(echo "${wanted}" | sort) <(echo "${installed}" | sort) | xargs -n1 code --uninstall-extension
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
alias python="python3"
alias serve="python -m http.server"
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

# nvm
export NVM_DIR="${HOME}/.nvm"
safe_source "${NVM_DIR}/nvm.sh"
safe_source "${NVM_DIR}/bash_completion"

# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
prepend_path "${PNPM_HOME}"

# bun
export BUN_INSTALL="${HOME}/.bun"
prepend_path "${BUN_INSTALL}/bin"
safe_source "${HOME}/.bun/_bun"

# uv
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

# gcloud
safe_source "${HOME}/google-cloud-sdk/path.zsh.inc"
safe_source "${HOME}/google-cloud-sdk/completion.zsh.inc"
alias gc="gcloud"
alias gcad="gcloud auth application-default login"
# export current gcloud project as env vars
gci() {
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
gcf() {
  local project_id="$(gcloud projects list --format="value(projectId)" | fzf --height 40% --layout reverse --border)"
  if [[ -n "${project_id}" ]]; then
    gcloud config set project "${project_id}"
    gci
  fi
}

# claude code
prepend_path "${HOME}/.local/bin"
alias cld="claude --dangerously-skip-permissions"
alias cldr="claude --dangerously-skip-permissions --resume"

# opencode
alias oc="opencode"
alias ocr="opencode -c"

# custom scripts
prepend_path "${HOME}/bin"
