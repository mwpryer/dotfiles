# source file if it exists
safe_source() {
  [[ -s "$1" ]] && source "$1"
}

# history
export HISTFILE="${HOME}/.histfile"
export HISTSIZE=100000
export SAVEHIST=100000
setopt extended_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

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
