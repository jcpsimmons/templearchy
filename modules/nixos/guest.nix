{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.kernelParams = [
    "console=tty0"
    "console=ttyAMA0,115200"
    "video=Virtual-1:1440x900@60"
  ];
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "virtio_net"
    "virtio_gpu"
    "virtio_9p"
    "9p"
    "9pnet_virtio"
    "xhci_pci"
  ];

  # Generators override this. Bare `nixos-rebuild` / build-vm needs a default.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  virtualisation.diskSize = 20480;

  fileSystems."/mnt/host" = {
    device = "hostshare";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "msize=104857600"
      "nofail"
    ];
  };
}
