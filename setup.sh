#!/usr/bin/env bash
# set up dotfiles and tmux plugins

TMUX_PLUGIN_DIR="${HOME}/.config/tmux/plugins"

# symlink dotfiles, --no-folding avoids symlinking entire dirs
cd "${HOME}/dotfiles" && stow --no-folding .

# tmux plugins
if [[ ! -d "${TMUX_PLUGIN_DIR}/tpm" ]]; then
  git clone https://github.com/tmux-plugins/tpm "${TMUX_PLUGIN_DIR}/tpm"
fi
if [[ ! -d "${TMUX_PLUGIN_DIR}/catppuccin/tmux" ]]; then
  mkdir -p "${TMUX_PLUGIN_DIR}/catppuccin"
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "${TMUX_PLUGIN_DIR}/catppuccin/tmux"
fi
"${TMUX_PLUGIN_DIR}/tpm/bin/install_plugins"
