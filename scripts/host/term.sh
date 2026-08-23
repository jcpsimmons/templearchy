#!/usr/bin/env bash
# Open Josh's WezTerm (BigBlueTerm / Homebrew Gogh) into the guest over SSH.
set -euo pipefail

PORT="${TEMPLEARCHY_SSH:-2222}"
USER_NAME="${TEMPLEARCHY_USER:-josh}"
PASS="${TEMPLEARCHY_PASS:-temple}"
HOST="${TEMPLEARCHY_HOST:-127.0.0.1}"

ssh_cmd=(
  ssh
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o PreferredAuthentications=password
  -o PubkeyAuthentication=no
  -p "${PORT}"
  "${USER_NAME}@${HOST}"
)

if [[ $# -gt 0 ]]; then
  ssh_cmd+=(-- "$@")
fi

run_ssh() {
  if command -v sshpass >/dev/null 2>&1; then
    exec sshpass -p "${PASS}" "${ssh_cmd[@]}"
  fi
  exec "${ssh_cmd[@]}"
}

# Host WezTerm keeps the CRT / BigBlueTerm look. Cocoa is the i3 desktop.
if [[ "${TEMPLEARCHY_PLAIN_SSH:-0}" != "1" ]] && command -v wezterm >/dev/null 2>&1; then
  if command -v sshpass >/dev/null 2>&1; then
    exec wezterm start -- sshpass -p "${PASS}" "${ssh_cmd[@]}"
  fi
  exec wezterm start -- "${ssh_cmd[@]}"
fi

run_ssh
