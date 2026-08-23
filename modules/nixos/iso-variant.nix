{ lib, ... }:
{
  # Live media for the Mac cocoa launcher. Must be EFI or AAVMF will not boot it.
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  isoImage.edition = "templearchy";
  isoImage.appendToMenuLabel = " i3";

  fileSystems."/mnt/host" = lib.mkForce {
    device = "hostshare";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "msize=104857600"
      "nofail"
      "x-systemd.device-timeout=1"
    ];
  };
}
