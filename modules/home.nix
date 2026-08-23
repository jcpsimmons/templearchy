{ pkgs, ... }:
{
  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    aichat
    neovim
    nodejs_22
    wezterm
  ];

  xdg.enable = true;
  xdg.configFile."wezterm/wezterm.lua".source = ../dotfiles/wezterm.lua;
  xdg.configFile."i3/config".source = ../dotfiles/i3/config;
  xdg.configFile."i3status/config".source = ../dotfiles/i3status/config;
  xdg.configFile."rofi/config.rasi".source = ../dotfiles/rofi/config.rasi;
  xdg.configFile."nvim".source = ../vendor/nvim;

  home.file.".tmux.conf".source = ../dotfiles/tmux.conf;
  home.file.".local/bin/q" = {
    source = ../scripts/guest/q;
    executable = true;
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      echo
      echo "TEMPLEARCHY"
      echo "NIX CONFIGURES EVERYTHING"
      echo "i3 · wezterm · BigBlueTerm437 · nvim · q queue"
      echo "Super+Return temple  Super+n nvim  Super+g files  Super+t queue"
      echo "from the Mac: nix run github:jcpsimmons/templearchy#q -- add 'prompt'"
      echo
    '';
    functions = {
      qadd = ''
        q add $argv
      '';
    };
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
