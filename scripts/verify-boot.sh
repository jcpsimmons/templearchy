#!/usr/bin/env bash
# Boot the guest and prove SSH + i3 + nvim + the q queue from the Mac host.
set -euo pipefail

ISO="${TEMPLEARCHY_IMAGE:-${HOME}/.local/share/templearchy/templearchy-aarch64.iso}"
PORT="${TEMPLEARCHY_SSH:-2222}"
CACHE="${TEMPLEARCHY_CACHE:-${HOME}/.local/share/templearchy}"
STAMP="${CACHE}/last-boot-probe.txt"
LOG="${CACHE}/verify-boot.log"
export TEMPLEARCHY_PASS="${TEMPLEARCHY_PASS:-temple}"
export TEMPLEARCHY_USER="${TEMPLEARCHY_USER:-josh}"
export TEMPLEARCHY_SSH_PORT="${PORT}"
DEADLINE="${TEMPLEARCHY_VERIFY_SECONDS:-180}"

if [[ ! -f "${ISO}" ]]; then
  echo "missing ISO at ${ISO}" >&2
  echo "set TEMPLEARCHY_IMAGE or fetch the nightly first" >&2
  exit 1
fi

mkdir -p "${CACHE}"
: >"${LOG}"

cleanup() {
  if [[ -n "${QEMU_PID:-}" ]] && kill -0 "${QEMU_PID}" 2>/dev/null; then
    kill "${QEMU_PID}" 2>/dev/null || true
    wait "${QEMU_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "verify boot: ${ISO}"
echo "ssh: ${TEMPLEARCHY_USER}@127.0.0.1:${PORT}"
echo "log: ${LOG}"

TEMPLEARCHY_IMAGE="${ISO}" \
  TEMPLEARCHY_DISPLAY="${TEMPLEARCHY_DISPLAY:-none}" \
  TEMPLEARCHY_SSH="${PORT}" \
  templearchy >>"${LOG}" 2>&1 &
QEMU_PID=$!

guest() {
  export TEMPLEARCHY_REMOTE_CMD="$1"
  expect <<'EOF'
set timeout 20
log_user 0
spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=5 -p $env(TEMPLEARCHY_SSH_PORT) $env(TEMPLEARCHY_USER)@127.0.0.1 -- $env(TEMPLEARCHY_REMOTE_CMD)
expect {
  -re "(?i)password:" { send -- "$env(TEMPLEARCHY_PASS)\r"; exp_continue }
  eof
}
log_user 1
catch wait result
exit [lindex $result 3]
EOF
}

echo "waiting up to ${DEADLINE}s for ssh"
start="$(date +%s)"
host=""
while true; do
  if ! kill -0 "${QEMU_PID}" 2>/dev/null; then
    echo "qemu exited before ssh came up" >&2
    tail -n 40 "${LOG}" >&2 || true
    exit 1
  fi
  if host="$(guest hostname 2>/dev/null | tr -d '[:space:]')" && [[ -n "${host}" ]]; then
    break
  fi
  now="$(date +%s)"
  if (( now - start > DEADLINE )); then
    echo "ssh did not answer on port ${PORT} in ${DEADLINE}s" >&2
    tail -n 40 "${LOG}" >&2 || true
    exit 1
  fi
  sleep 3
done

i3_line="$(guest 'pgrep i3' 2>/dev/null || true)"
nvim_bin="$(guest 'test -x /run/current-system/sw/bin/nvim && echo /run/current-system/sw/bin/nvim' 2>/dev/null || true)"
wez_bin="$(guest 'pgrep wezterm-gui' 2>/dev/null || true)"
q_bin="$(guest 'test -x /home/josh/.local/bin/q && echo /home/josh/.local/bin/q' 2>/dev/null || true)"
tmux_sess="$(guest 'pgrep tmux' 2>/dev/null || true)"

{
  echo "boot probe $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "iso ${ISO}"
  echo "hostname ${host}"
  echo "i3 ${i3_line}"
  echo "nvim ${nvim_bin}"
  echo "wezterm ${wez_bin}"
  echo "q ${q_bin}"
  echo "tmux ${tmux_sess}"
} | tee "${STAMP}"

fail=0
[[ "${host}" == "templearchy" ]] || { echo "hostname is ${host}, want templearchy" >&2; fail=1; }
[[ "${i3_line}" == *i3* ]] || { echo "i3 is not running" >&2; fail=1; }
[[ "${nvim_bin}" == *nvim* ]] || { echo "nvim missing" >&2; fail=1; }
[[ "${q_bin}" == *q* ]] || { echo "q missing" >&2; fail=1; }
exit "${fail}"
