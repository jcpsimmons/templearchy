#!/usr/bin/env bash
# templearchy host launcher. Nix owns qemu, firmware, and the guest image.
# Boots a cocoa window on Apple Silicon. Prefers ISO (no KVM to build).
set -euo pipefail

REPO="${TEMPLEARCHY_REPO:-jcpsimmons/templearchy}"
FLAKE="${TEMPLEARCHY_FLAKE:-github:${REPO}}"
CACHE="${TEMPLEARCHY_CACHE:-${HOME}/.local/share/templearchy}"
SHARE="${TEMPLEARCHY_SHARE:-${HOME}/templearchy-share}"
MEM="${TEMPLEARCHY_MEM:-8192}"
CPUS="${TEMPLEARCHY_CPUS:-6}"
SSH_PORT="${TEMPLEARCHY_SSH:-2222}"
DISPLAY_MODE="${TEMPLEARCHY_DISPLAY:-cocoa}"
WIDTH="${TEMPLEARCHY_WIDTH:-1440}"
HEIGHT="${TEMPLEARCHY_HEIGHT:-900}"

mkdir -p "${CACHE}" "${SHARE}"

say() {
  echo "$*"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    osascript -e "display notification \"$*\" with title \"TEMPLEARCHY\"" >/dev/null 2>&1 || true
  fi
}

say "NIX CONFIGURES EVERYTHING"
echo "i3 in a Mac window"
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

copy_from_store() {
  local out="$1"
  local pattern="$2"
  local dest="$3"
  local found
  found="$(find -L "${out}" -name "${pattern}" -print -quit 2>/dev/null || true)"
  if [[ -z "${found}" ]]; then
    return 1
  fi
  cp -f "${found}" "${dest}"
  echo "${dest}"
}

fetch_release() {
  local name="$1"
  local dest="$2"
  local url="https://github.com/${REPO}/releases/download/nightly/${name}"
  echo "fetch ${url}" >&2
  if curl -fL --retry 3 "${url}" -o "${dest}.zst"; then
    zstd -d -f "${dest}.zst" -o "${dest}"
    echo "${dest}"
    return 0
  fi
  return 1
}

resolve_boot() {
  # prints: KIND PATH
  if [[ -n "${TEMPLEARCHY_IMAGE:-}" ]]; then
    if [[ "${TEMPLEARCHY_IMAGE}" == *.iso ]]; then
      echo "iso ${TEMPLEARCHY_IMAGE}"
    else
      echo "disk ${TEMPLEARCHY_IMAGE}"
    fi
    return
  fi

  if [[ -f "${CACHE}/templearchy-aarch64.qcow2" ]]; then
    echo "disk ${CACHE}/templearchy-aarch64.qcow2"
    return
  fi

  if [[ -f "${CACHE}/templearchy-aarch64.iso" ]]; then
    echo "iso ${CACHE}/templearchy-aarch64.iso"
    return
  fi

  echo "no local guest image; nightly first (Darwin cannot build aarch64-linux)" >&2
  say "Fetching nightly ISO from GitHub"

  if fetch_release "templearchy-aarch64.iso.zst" "${CACHE}/templearchy-aarch64.iso" >/dev/null; then
    echo "iso ${CACHE}/templearchy-aarch64.iso"
    return
  fi
  if fetch_release "templearchy-aarch64.qcow2.zst" "${CACHE}/templearchy-aarch64.qcow2" >/dev/null; then
    echo "disk ${CACHE}/templearchy-aarch64.qcow2"
    return
  fi

  # Optional local build. Off by default on Darwin — it needs a Linux builder.
  if [[ "${TEMPLEARCHY_BUILD:-0}" == "1" ]] && command -v nix >/dev/null 2>&1; then
    local store_path=""
    if store_path="$(nix build --no-link --print-out-paths "${FLAKE}#packages.aarch64-linux.iso" 2>/tmp/templearchy-nix-build.log)"; then
      if copy_from_store "${store_path}" '*.iso' "${CACHE}/templearchy-aarch64.iso" >/dev/null; then
        echo "iso ${CACHE}/templearchy-aarch64.iso"
        return
      fi
    fi
  fi

  echo "no guest image" >&2
  echo "CI builds an ISO without KVM. After the nightly release:" >&2
  echo "  nix run ${FLAKE}" >&2
  echo "or build locally with a Linux builder:" >&2
  echo "  nix build ${FLAKE}#packages.aarch64-linux.iso" >&2
  if [[ -f /tmp/templearchy-nix-build.log ]]; then
    echo "--- nix build log (tail) ---" >&2
    tail -n 40 /tmp/templearchy-nix-build.log >&2 || true
  fi
  exit 1
}

read -r BOOT_KIND BOOT_PATH <<<"$(resolve_boot)"
echo "boot:  ${BOOT_KIND} ${BOOT_PATH}"
echo "qemu:  ${QEMU_BIN}"
echo "uefi:  ${FIRMWARE}"
echo "share: ${SHARE}  ->  /mnt/host"
echo "ssh:   ssh josh@127.0.0.1 -p ${SSH_PORT}   (password: temple)"
echo

VARS="${CACHE}/vars.fd"
if [[ ! -f "${VARS}" && -f "${VARS_SRC}" ]]; then
  cp "${VARS_SRC}" "${VARS}"
elif [[ ! -f "${VARS}" ]]; then
  dd if=/dev/zero of="${VARS}" bs=1m count=64 >/dev/null 2>&1
fi

PERSIST="${CACHE}/persist.qcow2"
if [[ ! -f "${PERSIST}" ]]; then
  qemu-img create -f qcow2 "${PERSIST}" 20G >/dev/null
fi

ACCEL=tcg
if [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ACCEL=hvf
  elif [[ -e /dev/kvm ]]; then
    ACCEL=kvm
  fi
fi

DISPLAY_ARGS=(-display "${DISPLAY_MODE},show-cursor=on")
if [[ "${DISPLAY_MODE}" == "cocoa" ]]; then
  DISPLAY_ARGS=(-display "cocoa,show-cursor=on,zoom-to-fit=on")
fi
if [[ "${DISPLAY_MODE}" == "none" ]]; then
  DISPLAY_ARGS=(-nographic)
fi

MEDIA_ARGS=()
if [[ "${BOOT_KIND}" == "iso" ]]; then
  MEDIA_ARGS+=(
    -cdrom "${BOOT_PATH}"
    -drive "if=virtio,file=${PERSIST},format=qcow2"
    -boot d
  )
else
  MEDIA_ARGS+=(
    -drive "if=virtio,file=${BOOT_PATH},format=qcow2"
  )
fi

exec "${QEMU_BIN}" \
  -name templearchy \
  -machine virt,highmem=on,accel="${ACCEL}" \
  -cpu host \
  -smp "${CPUS}" \
  -m "${MEM}" \
  -drive if=pflash,format=raw,readonly=on,file="${FIRMWARE}" \
  -drive if=pflash,format=raw,file="${VARS}" \
  "${MEDIA_ARGS[@]}" \
  -device "virtio-gpu-pci,xres=${WIDTH},yres=${HEIGHT}" \
  "${DISPLAY_ARGS[@]}" \
  -device qemu-xhci \
  -device usb-kbd \
  -device usb-tablet \
  -device virtio-net-pci,netdev=net0 \
  -netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22" \
  -virtfs "local,path=${SHARE},mount_tag=hostshare,security_model=mapped-xattr" \
  -serial mon:stdio
