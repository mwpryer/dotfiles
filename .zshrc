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

path=("${HOME}/bin" "${HOME}/.local/bin" $path)

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

# upgrade packages
if command -v brew &>/dev/null; then
  alias up="brew update && brew upgrade && brew autoremove && brew cleanup"
elif command -v yay &>/dev/null; then
  alias up="yay -Syu && yay -Sc"
elif command -v pacman &>/dev/null; then
  alias up="sudo pacman -Syu && sudo pacman -Sc"
fi

# prompt
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
eval "$(starship init zsh)"

# aliases and functions
for f in "${HOME}"/.config/zsh/*.zsh; do
  source "${f}"
done
