{ pkgs, ... }:
let
  palette = import ../palette.nix;
in
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      fuzzel
      grim
      slurp
      swaybg
      waybar
      wezterm
      wl-clipboard
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "josh";
      };
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "josh";
      };
    };
  };

  hardware.graphics.enable = true;

  fonts.packages = [
    pkgs.nerd-fonts.bigblue-terminal
    pkgs.nerd-fonts.symbols-only
  ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ palette.font ];

  environment.sessionVariables = {
    WLR_RENDERER = "pixman";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.dconf.enable = true;
}
