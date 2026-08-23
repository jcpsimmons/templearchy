{ pkgs, ... }:
{
  home.username = "josh";
  home.homeDirectory = "/home/josh";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    neovim
    nodejs_22
    wezterm
  ];

  xdg.enable = true;
  xdg.configFile."wezterm/wezterm.lua".source = ../dotfiles/wezterm.lua;
  xdg.configFile."sway/config".source = ../dotfiles/sway/config;
  xdg.configFile."waybar/config".source = ../dotfiles/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../dotfiles/waybar/style.css;
  xdg.configFile."fuzzel/fuzzel.ini".source = ../dotfiles/fuzzel/fuzzel.ini;
  xdg.configFile."nvim".source = ../vendor/nvim;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      echo
      echo "TEMPLEARCHY"
      echo "NIX CONFIGURES EVERYTHING"
      echo "wezterm · BigBlueTerm437 · nvim murphy"
      echo
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
