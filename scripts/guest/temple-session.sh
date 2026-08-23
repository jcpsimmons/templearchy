#!/usr/bin/env bash
# One WezTerm: nvim left, shell right, queue window. Attach if temple already exists.
set -euo pipefail

if tmux has-session -t temple 2>/dev/null; then
  exec wezterm start -- tmux attach -t temple
fi

tmux new-session -d -s temple -n nvim nvim
tmux split-window -h -t temple:nvim
tmux new-window -t temple -n queue -- q watch
tmux select-window -t temple:nvim
tmux select-pane -t temple:nvim.1

exec wezterm start -- tmux attach -t temple
