{ pkgs, ... }:
let
  palette = import ../palette.nix;
in
{
  # X11 + i3: simple tiling, reliable in a QEMU cocoa window on a Mac host.
  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.videoDrivers = [
    "modesetting"
    "fbdev"
  ];
  services.xserver.xkb.layout = "us";
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      dmenu
      i3status
      rofi
      xclip
      xrandr
      xsetroot
    ];
  };

  services.displayManager.defaultSession = "none+i3";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "josh";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.greeters.mini = {
    enable = true;
    user = "josh";
    extraConfig = ''
      [greeter]
      show-password-label = false
      [greeter-theme]
      font = "${palette.font}"
      font-size = 14
      background-image = ""
      background-color = "#000000"
      window-color = "#000000"
      border-color = "#00ffff"
      border-width = 4px
      text-color = "#00ff00"
      password-background-color = "#000000"
      password-border-color = "#00ffff"
    '';
  };

  hardware.graphics.enable = true;

  fonts.packages = [
    pkgs.nerd-fonts.bigblue-terminal
    pkgs.nerd-fonts.symbols-only
  ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ palette.font ];

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    XDG_CURRENT_DESKTOP = "i3";
    XDG_SESSION_TYPE = "x11";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    pcmanfm
    qutebrowser
    wezterm
  ];
}
