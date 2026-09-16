export EDITOR="code"
export VISUAL="code --wait"

typeset -U PATH path
path=(
  "${HOME}/bin"
  "${HOME}/.local/bin"
  "${HOME}/.local/share/mise/shims"
  "${HOME}/.bun/bin"
  $path
)
