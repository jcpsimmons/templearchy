{ pkgs, ... }:
{
  # CLI-first LLM / neovim workstation. No API keys in the repo.
  environment.systemPackages = with pkgs; [
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
  ];

  programs.tmux.enable = true;
  programs.direnv.enable = true;
}
