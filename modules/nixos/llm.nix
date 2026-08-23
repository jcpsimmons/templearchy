{ pkgs, lib, ... }:
let
  q = pkgs.writeShellApplication {
    name = "q";
    runtimeInputs = [
      pkgs.aichat
      pkgs.coreutils
      pkgs.findutils
    ];
    text = lib.removePrefix "#!/usr/bin/env bash\n" (builtins.readFile ../../scripts/guest/q);
  };
  temple-session = pkgs.writeShellApplication {
    name = "temple-session";
    runtimeInputs = [
      pkgs.neovim
      pkgs.tmux
      pkgs.wezterm
      q
    ];
    text = lib.removePrefix "#!/usr/bin/env bash\n" (builtins.readFile ../../scripts/guest/temple-session.sh);
  };
in
{
  # CLI-first LLM / neovim workstation. No API keys in the repo.
  environment.systemPackages = [
    q
    temple-session
  ]
  ++ (with pkgs; [
    aichat
    bat
    delta
    fd
    fzf
    gh
    git
    jq
    lazygit
    neovim
    nodejs_22
    python3
    ripgrep
    tmux
    tree
  ]);

  programs.tmux.enable = true;
  programs.direnv.enable = true;
}
