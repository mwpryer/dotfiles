# shell
alias dotfiles="${VISUAL:-${EDITOR}} -n ${HOME}/dotfiles"
alias sysfiles="${VISUAL:-${EDITOR}} -n ${HOME}/sysfiles"
alias s="source ${HOME}/.zshrc"
alias c="clear"

# navigation
# zoxide
eval "$(zoxide init --cmd cd zsh)"
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
--height 40% --reverse --border"
# fd as fzf backend
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
# fuzzy-find file, open in editor
vf() { local file="$(fzf)" && [[ -n "${file}" ]] && "${EDITOR}" "${file}"; }

# atuin, after fzf so it owns ctrl-r
eval "$(atuin init zsh --disable-up-arrow)"

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
tmaf() {
  local session="$(tmux ls -F '#{session_name}' 2>/dev/null | fzf)"
  [[ -n "${session}" ]] && tmux attach -t "${session}"
}

# herdr
alias hd="herdr"
alias hdr="herdr --remote"
hdw() { herdr workspace create --cwd "${1:-$PWD}" --focus >/dev/null && ! pgrep -f '^herdr$' >/dev/null && herdr }

# yazi
# drop into current dir on exit
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="${tmp}"
  IFS= read -r -d '' cwd < "${tmp}"
  [[ -n "${cwd}" ]] && [[ "${cwd}" != "${PWD}" ]] && builtin cd -- "${cwd}"
  rm -f -- "${tmp}"
}
