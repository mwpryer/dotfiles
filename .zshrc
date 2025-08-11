export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=1000
export EDITOR="nvim"
export VISUAL="code --wait"
# override lazygit config file for mac
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
# set gpg tty for signing commits
export GPG_TTY=$(tty)

# zsh options
setopt beep
setopt extendedglob
setopt nomatch
setopt notify
# vi mode
bindkey -v
# completion system
autoload -Uz compinit
compinit
# zsh plugins
source ~/.config/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# zsh plugins for mac
# source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# shell prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# smart cd, alias cd to zoxide
eval "$(zoxide init --cmd cd zsh)"

# fuzzy finder
eval "$(fzf --zsh)"
# Catppuccin Mocha theme (https://github.com/catppuccin/fzf)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# shell management
alias dotfiles="${VISUAL:-${EDITOR}} ~/dotfiles"
alias s="source ~/.zshrc"
alias c="clear"

# file management
alias ..="cd .."
alias ...="cd ../.."
alias mkd="mkdir -pv"
function mkcd() {
  mkdir -p "$1" && cd "$1"
}
alias mv="mv -vi"
alias cp="cp -vi"
alias rm="rm -vI"
alias ls="eza -a --icons --group-directories-first"
alias ll="eza -lahF --icons  --git --group-directories-first"
alias lt="eza --long --tree --level=3 --icons  --git --group-directories-first --ignore-glob node_modules"
alias cat="bat"
# colourise help output with bat
alias -g -- -h="-h 2>&1 | bat --language=help --style=plain"
alias -g -- --help="--help 2>&1 | bat --language=help --style=plain"
# set bat as colourising pager for man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
# fuzzy find files with syntax highlighting preview
alias fzfp="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
# trash management
alias trp="trash-put"
alias trl="trash-list"
alias trr="trash-restore"

# applications
alias v="nvim"
alias g="git"
alias lg="lazygit"
alias dk="docker"
alias dkc="docker-compose"
alias ldk="lazydocker"
alias k="kubectl"
alias tm="tmux"
alias gc="gcloud"
alias gcad="gcloud auth application-default login"
# start new tmux session with current directory name
alias tmn="tmux new -s $(pwd | sed 's/.*\///g')"
# yazi wrapper to drop out at the current directory
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
alias neofetch="neofetch --source $HOME/.config/neofetch/ascii.txt"

# development
alias ni="npm install"
alias nb="npm run build"
alias ns="npm start"
alias nd="npm run dev"
alias py="/usr/bin/python3"
alias python="/usr/bin/python3"
alias serve="python -m http.server"
# kill process by port
function killp() {
  lsof -ti:$1 | xargs kill
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# gcloud
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
# set current GC project as env vars
function init_gc() {
  project_id=$(gcloud config get core/project 2>/dev/null)
  project_number=$(gcloud projects describe ${project_id} --format="value(projectNumber)" 2>/dev/null)
  if [ -n "$project_id" ] && [ -n "$project_number" ]; then
    export GC_PROJECT_ID=$project_id
    export GC_PROJECT_NUMBER=$project_number
  else
    unset GC_PROJECT_ID
    unset GC_PROJECT_NUMBER
  fi
}
