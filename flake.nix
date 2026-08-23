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
            gh
            gnugrep
            gnused
            python3
            qemu
            zstd
          ];
          text = builtins.readFile ./scripts/launch.sh;
        };

      mkVerify =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.writeShellApplication {
          name = "templearchy-verify";
          runtimeInputs = [
            (mkLaunch system)
            pkgs.coreutils
            pkgs.expect
            pkgs.openssh
          ];
          text = builtins.readFile ./scripts/verify-boot.sh;
        };

      mkHostQ =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.writeShellApplication {
          name = "q";
          runtimeInputs = with pkgs; [
            coreutils
            findutils
          ];
          text = ''
            export TEMPLEARCHY_QUEUE="''${TEMPLEARCHY_QUEUE:-''${TEMPLEARCHY_SHARE:-$HOME/templearchy-share}/queue}"
          ''
          + lib.removePrefix "#!/usr/bin/env bash\n" (builtins.readFile ./scripts/guest/q);
        };

      mkTerm =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.writeShellApplication {
          name = "templearchy-term";
          runtimeInputs = with pkgs; [
            openssh
            sshpass
          ];
          text = lib.removePrefix "#!/usr/bin/env bash\n" (builtins.readFile ./scripts/host/term.sh);
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
          verify = mkVerify system;
          q = mkHostQ system;
          term = mkTerm system;
        in
        {
          default = launch;
          launch = launch;
          verify = verify;
          q = q;
          term = term;
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
        verify = {
          type = "app";
          program = lib.getExe self.packages.${system}.verify;
        };
        q = {
          type = "app";
          program = lib.getExe self.packages.${system}.q;
        };
        term = {
          type = "app";
          program = lib.getExe self.packages.${system}.term;
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
            grep -q 'temple-session' ${./dotfiles/i3/config}
            grep -q 'pcmanfm' ${./dotfiles/i3/config}
            test -x ${./scripts/guest/q}
            grep -q '/mnt/host/queue' ${./scripts/guest/q}
            test -x ${./scripts/guest/temple-session.sh}
            grep -q 'Templearchy' ${./macos/Templearchy.app/Contents/MacOS/Templearchy}
            grep -q 'pgrep i3' ${./scripts/verify-boot.sh}
            grep -q 'edk2-arm-vars.fd' ${./scripts/launch.sh}
            grep -q 'bs=1M' ${./scripts/launch.sh}
            grep -q "pattern 'templearchy-aarch64.iso.zst'" ${./scripts/launch.sh}
            grep -q 'wezterm start' ${./scripts/host/term.sh}
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
