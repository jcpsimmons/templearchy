{
  pkgs,
  lib,
  ...
}:
let
  palette = import ../palette.nix;
in
{
  imports = [
    ./desktop.nix
    ./guest.nix
    ./llm.nix
  ];

  # Merges with nixpkgs iso-image.nix. Do not replace the attr.
  image.modules.iso = ./iso-variant.nix;

  networking.hostName = "templearchy";
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  time.timeZone = "America/Phoenix";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.warn-dirty = false;
  nixpkgs.config.allowUnfree = true;

  users.mutableUsers = false;
  users.users.josh = {
    isNormalUser = true;
    description = "Josh";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "networkmanager"
    ];
    initialPassword = "temple";
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  programs.fish.enable = true;
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    coreutils
    curl
    fd
    file
    git
    jq
    pciutils
    ripgrep
    tree
    unzip
    vim
    wget
  ];

  environment.etc.issue.text = ''
    TEMPLEARCHY
    NIX CONFIGURES EVERYTHING
    NOT TASTEFUL

    user: josh
    pass: temple
    ssh:  host port 2222 -> guest 22

  '';

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERM = "wezterm";
  };

  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    colors = palette.ansi ++ palette.brights;
    keyMap = "us";
  };

  system.stateVersion = "25.05";
}
