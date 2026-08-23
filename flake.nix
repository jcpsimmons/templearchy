{
  description = "templearchy — Nix-configured Omarchy alternative. Harsh high-contrast. One-click on Apple Silicon.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      inherit (nixpkgs) lib;
      guestSystem = "aarch64-linux";
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems f;
      mkPkgs = system: import nixpkgs { inherit system; };

      commonModules = [
        ./modules/nixos
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.josh = import ./modules/home.nix;
        }
      ];

      mkLaunch =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.writeShellApplication {
          name = "templearchy";
          runtimeInputs = with pkgs; [
            coreutils
            curl
            gnugrep
            gnused
            python3
            qemu
            zstd
          ];
          text = builtins.readFile ./scripts/launch.sh;
        };
    in
    {
      nixosConfigurations.templearchy = nixpkgs.lib.nixosSystem {
        system = guestSystem;
        modules = commonModules;
        specialArgs = { inherit self; };
      };

      packages = forAllSystems (
        system:
        let
          launch = mkLaunch system;
        in
        {
          default = launch;
          launch = launch;
        }
        // lib.optionalAttrs (system == guestSystem) {
          # ISO does not need KVM. qcow2 still does (linux-builder / local kvm).
          iso = self.nixosConfigurations.templearchy.config.system.build.images.iso;
          qcow2 = self.nixosConfigurations.templearchy.config.system.build.images.qemu-efi;
          toplevel = self.nixosConfigurations.templearchy.config.system.build.toplevel;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = lib.getExe self.packages.${system}.launch;
        };
        launch = {
          type = "app";
          program = lib.getExe self.packages.${system}.launch;
        };
      });

      checks = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          hostname = pkgs.runCommand "templearchy-hostname" { } ''
            test "${self.nixosConfigurations.templearchy.config.networking.hostName}" = "templearchy"
            touch "$out"
          '';
          user = pkgs.runCommand "templearchy-user" { } ''
            test "${self.nixosConfigurations.templearchy.config.users.users.josh.name}" = "josh"
            touch "$out"
          '';
          wezterm-dotfile = pkgs.runCommand "templearchy-wezterm" { } ''
            grep -q 'Homebrew (Gogh)' ${./dotfiles/wezterm.lua}
            grep -q 'BigBlueTerm437 Nerd Font' ${./dotfiles/wezterm.lua}
            touch "$out"
          '';
          nvim-vendor = pkgs.runCommand "templearchy-nvim" { } ''
            test -f ${./vendor/nvim/init.lua}
            grep -q 'murphy' ${./vendor/nvim/lua/plugins/themes.lua}
            touch "$out"
          '';
          i3-dotfile = pkgs.runCommand "templearchy-i3" { } ''
            grep -q 'set \$mod Mod4' ${./dotfiles/i3/config}
            grep -q 'wezterm' ${./dotfiles/i3/config}
            grep -q 'pcmanfm' ${./dotfiles/i3/config}
            test -x ${./scripts/guest/q}
            grep -q 'Templearchy' ${./macos/Templearchy.app/Contents/MacOS/Templearchy}
            touch "$out"
          '';
          efi-iso =
            if system == guestSystem then
              pkgs.runCommand "templearchy-efi-iso" { } ''
                test "${toString self.nixosConfigurations.templearchy.config.system.build.images.iso.passthru.config.isoImage.makeEfiBootable}" = "1"
                touch "$out"
              ''
            else
              pkgs.runCommand "templearchy-efi-iso-skip" { } "touch $out";
        }
      );

      formatter = forAllSystems (system: (mkPkgs system).nixfmt);
    };
}
