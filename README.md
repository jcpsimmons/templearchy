# TEMPLEARCHY

Nix-configured Omarchy alternative.

Not tasteful. Harsh high-contrast. BigBlueTerm437. Homebrew green. Murphy nvim. i3 in a Mac window.

```
nix run github:jcpsimmons/templearchy
```

Or double-click `macos/Templearchy.app`. Nix still owns qemu, firmware, and the guest.

## What you get

- NixOS aarch64 guest, defined in `flake.nix`
- i3 + X11 (simple tiling, cocoa GUI on the Mac host)
- WezTerm with `Homebrew (Gogh)`, BigBlueTerm437, saturation 1.4
- Vendored Neovim (`murphy`) + tmux session `temple`
- `q` prompt queue for LLM work (`q add`, `q drain` via aichat)
- pcmanfm file GUI. No QtWebEngine browser — that alone blew the 2GB GitHub release cap.
- User `josh` / password `temple`
- SSH `2222`, host folder `~/templearchy-share` -> `/mnt/host`

## One-click on Apple Silicon

1. Install Determinate Nix
2. `nix run github:jcpsimmons/templearchy` or open `macos/Templearchy.app`
3. A QEMU cocoa window opens. i3 autologins.

Guest media is a live ISO built without KVM (GHA `ubuntu-24.04-arm`). Nightly: `jcpsimmons/templearchy` releases. A 20G persist disk is created beside it.

```
TEMPLEARCHY_MEM=16384 TEMPLEARCHY_CPUS=8 nix run .
```

## Keys

| Key | Action |
| --- | --- |
| Super+Enter | WezTerm |
| Super+Shift+Enter | WezTerm + tmux `temple` |
| Super+n | nvim |
| Super+g | files |
| Super+t | queue tmux |
| Super+e | files |
| Super+d | rofi |
| Super+h/j/k/l | focus |

## Queue

```
q add rewrite this function
q list
q drain
```

`q drain` runs `aichat`. No API keys are in the repo. Export yours in the guest.

## Edit the look

Nix owns it.

| Thing | File |
| --- | --- |
| Colors | `modules/palette.nix` |
| i3 / X11 | `modules/nixos/desktop.nix`, `dotfiles/i3/` |
| LLM / nvim tools | `modules/nixos/llm.nix` |
| WezTerm | `dotfiles/wezterm.lua` |
| Neovim | `vendor/nvim/` |
| Host launch | `scripts/launch.sh`, `macos/Templearchy.app` |

Default branch is `master`. No secrets.
