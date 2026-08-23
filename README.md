# TEMPLEARCHY

Nix-configured Omarchy alternative.

Not tasteful. Harsh high-contrast. BigBlueTerm437. Homebrew green. Murphy nvim. Cyan chrome on black.

Omarchy is a beautiful Arch/Hyprland desktop. This is the other pole: **Nix is the only configuration surface**, the guest is NixOS, and the host launcher is a Nix app. One command on an Apple Silicon Mac boots a Linux VM that looks like Josh's WezTerm / BigBlueTerm / Neovim setup.

```
nix run github:jcpsimmons/templearchy
```

That command is Nix all the way down: qemu, UEFI firmware, and the guest image come from the flake (or a nightly image the flake built).

## What you get

- NixOS aarch64 guest, defined in `flake.nix`
- Sway, 0 gaps, 0 radius, 4px cyan borders
- WezTerm with `Homebrew (Gogh)`, BigBlueTerm437, saturation 1.4, blinking block cursor
- Vendored Neovim config (`murphy` + `16color` lualine)
- User `josh` / password `temple` (published demo password, not a secret)
- SSH on host port `2222`

## One-click on Apple Silicon

1. Install Determinate Nix if you do not already have Nix
2. Run `nix run github:jcpsimmons/templearchy`
3. First boot needs a guest qcow2:
   - nightly release at `jcpsimmons/templearchy` (built from this flake on `ubuntu-24.04-arm`), or
   - local build via a Linux builder: `nix run nixpkgs#darwin.linux-builder` then `nix build .#packages.aarch64-linux.qcow2`

QEMU uses HVF. Default: 6 CPUs, 8G RAM.

```
TEMPLEARCHY_MEM=16384 TEMPLEARCHY_CPUS=8 nix run .
```

## Keys

| Key | Action |
| --- | --- |
| Super+Enter | WezTerm |
| Super+d | fuzzel |
| Super+q | kill window |
| Super+h/j/k/l | focus |
| Super+1..9 | workspace |

## Edit the look

Nix owns it. Do not configure the guest by hand.

| Thing | File |
| --- | --- |
| Colors | `modules/palette.nix` |
| Guest OS | `modules/nixos/` |
| WezTerm / Sway / Waybar | `dotfiles/` |
| Neovim | `vendor/nvim/` (brought over from `~/.config/nvim`) |
| Host launch | `scripts/launch.sh` wrapped by `flake.nix` |

CRT shaders from [wezterm-crt](https://github.com/jcpsimmons/wezterm-crt) are not in the guest. Regular WezTerm is pinned to the same palette and font.

## Bare metal / existing NixOS

```
sudo nixos-rebuild switch --flake github:jcpsimmons/templearchy#templearchy
```

Default branch is `master`.

## No secrets

Public repo. No tokens, no `.env`, no private keys. The VM password is `temple` on purpose.
