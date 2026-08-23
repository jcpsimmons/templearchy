#!/usr/bin/env bash
# templearchy host launcher. Nix owns qemu, firmware, and the guest image.
set -euo pipefail

REPO="${TEMPLEARCHY_REPO:-jcpsimmons/templearchy}"
FLAKE="${TEMPLEARCHY_FLAKE:-github:${REPO}}"
CACHE="${TEMPLEARCHY_CACHE:-${HOME}/.local/share/templearchy}"
MEM="${TEMPLEARCHY_MEM:-8192}"
CPUS="${TEMPLEARCHY_CPUS:-6}"
SSH_PORT="${TEMPLEARCHY_SSH:-2222}"
DISPLAY_MODE="${TEMPLEARCHY_DISPLAY:-cocoa}"

mkdir -p "${CACHE}"

echo "TEMPLEARCHY"
echo "NIX CONFIGURES EVERYTHING"
echo

QEMU_BIN="$(command -v qemu-system-aarch64)"
QEMU_PREFIX="$(dirname "$(dirname "${QEMU_BIN}")")"
FIRMWARE="${TEMPLEARCHY_FIRMWARE:-${QEMU_PREFIX}/share/qemu/edk2-aarch64-code.fd}"
VARS_SRC="${TEMPLEARCHY_VARS:-${QEMU_PREFIX}/share/qemu/edk2-aarch64-vars.fd}"

if [[ ! -f "${FIRMWARE}" ]]; then
  echo "missing UEFI firmware at ${FIRMWARE}" >&2
  echo "qemu came from Nix; if this path is wrong, set TEMPLEARCHY_FIRMWARE" >&2
  exit 1
fi

copy_qcow_from_store() {
  local out="$1"
  local found
  found="$(find -L "${out}" -name '*.qcow2' -print -quit 2>/dev/null || true)"
  if [[ -z "${found}" ]]; then
    return 1
  fi
  cp -f "${found}" "${CACHE}/templearchy-aarch64.qcow2"
  echo "${CACHE}/templearchy-aarch64.qcow2"
}

resolve_image() {
  if [[ -n "${TEMPLEARCHY_IMAGE:-}" ]]; then
    echo "${TEMPLEARCHY_IMAGE}"
    return
  fi

  if [[ -f "${CACHE}/templearchy-aarch64.qcow2" ]]; then
    echo "${CACHE}/templearchy-aarch64.qcow2"
    return
  fi

  echo "no local guest image; asking Nix, then GitHub nightly" >&2

  if command -v nix >/dev/null 2>&1; then
    local store_path=""
    if store_path="$(nix build --no-link --print-out-paths "${FLAKE}#packages.aarch64-linux.qcow2" 2>/tmp/templearchy-nix-build.log)"; then
      if copy_qcow_from_store "${store_path}"; then
        return
      fi
    fi
  fi

  local url="https://github.com/${REPO}/releases/download/nightly/templearchy-aarch64.qcow2.zst"
  echo "fetch ${url}" >&2
  if curl -fL --retry 3 "${url}" -o "${CACHE}/templearchy-aarch64.qcow2.zst"; then
    zstd -d -f "${CACHE}/templearchy-aarch64.qcow2.zst" -o "${CACHE}/templearchy-aarch64.qcow2"
    echo "${CACHE}/templearchy-aarch64.qcow2"
    return
  fi

  echo "no guest image" >&2
  echo "the guest is a NixOS system defined by this flake. build it with a Linux builder:" >&2
  echo "  nix run nixpkgs#darwin.linux-builder" >&2
  echo "  nix build ${FLAKE}#packages.aarch64-linux.qcow2" >&2
  echo "  TEMPLEARCHY_IMAGE=./result/*.qcow2 nix run ${FLAKE}" >&2
  if [[ -f /tmp/templearchy-nix-build.log ]]; then
    echo "--- nix build log (tail) ---" >&2
    tail -n 40 /tmp/templearchy-nix-build.log >&2 || true
  fi
  exit 1
}

IMAGE="$(resolve_image)"
echo "image: ${IMAGE}"
echo "qemu:  ${QEMU_BIN}"
echo "uefi:  ${FIRMWARE}"
echo "ssh:   ssh josh@127.0.0.1 -p ${SSH_PORT}   (password: temple)"
echo

VARS="${CACHE}/vars.fd"
if [[ ! -f "${VARS}" && -f "${VARS_SRC}" ]]; then
  cp "${VARS_SRC}" "${VARS}"
elif [[ ! -f "${VARS}" ]]; then
  dd if=/dev/zero of="${VARS}" bs=1m count=64 >/dev/null 2>&1
fi

ACCEL=tcg
if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ACCEL=hvf
  elif [[ -e /dev/kvm ]]; then
    ACCEL=kvm
  fi
fi

DISPLAY_ARGS=(-display "${DISPLAY_MODE}")
if [[ "${DISPLAY_MODE}" == "none" ]]; then
  DISPLAY_ARGS=(-nographic)
fi

exec "${QEMU_BIN}" \
  -name templearchy \
  -machine virt,highmem=on,accel="${ACCEL}" \
  -cpu host \
  -smp "${CPUS}" \
  -m "${MEM}" \
  -drive if=pflash,format=raw,readonly=on,file="${FIRMWARE}" \
  -drive if=pflash,format=raw,file="${VARS}" \
  -drive if=virtio,file="${IMAGE}",format=qcow2 \
  -device virtio-gpu-pci \
  "${DISPLAY_ARGS[@]}" \
  -device qemu-xhci \
  -device usb-kbd \
  -device usb-tablet \
  -device virtio-net-pci,netdev=net0 \
  -netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22" \
  -serial mon:stdio
