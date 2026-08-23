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
  xdg.configFile."qutebrowser/config.py".text = ''
    c.colors.webpage.darkmode.enabled = True
    c.colors.tabs.bar.bg = "#000000"
    c.colors.tabs.selected.even.bg = "#00ffff"
    c.colors.tabs.selected.even.fg = "#000000"
    c.colors.tabs.selected.odd.bg = "#00ffff"
    c.colors.tabs.selected.odd.fg = "#000000"
    c.colors.tabs.even.bg = "#000000"
    c.colors.tabs.even.fg = "#00ff00"
    c.colors.tabs.odd.bg = "#000000"
    c.colors.tabs.odd.fg = "#00ff00"
    c.fonts.default_family = "BigBlueTerm437 Nerd Font"
    c.fonts.default_size = "12pt"
    c.tabs.favicons.show = "never"
    c.scrolling.smooth = False
  '';

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
      echo "Super+Return term  Super+n nvim  Super+g web  Super+t queue"
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
