# shellcheck shell=sh

# . "${___X_CMD_ROOT_MOD}/xrc/latest"
. "${___X_CMD_ROOT_MOD}/xrc/latest"

___X_CMD_TMUX_BIN="${___X_CMD_TMUX_BIN:-tmux}"

$___X_CMD_TMUX_BIN bind b     display-popup -E "${SHELL:-/bin/sh} $___X_CMD_ROOT_MOD/tmux/lib/config/popup.sh"

# Plugin management
xrc:mod tmux/lib/config/plugin-util.sh

xrc:mod:lib     tmux \
                config/plugin-scroll.sh     \
                config/plugin-copy.sh       \
                config/plugin-control.sh    \
                config/plugin-theme-default.sh
