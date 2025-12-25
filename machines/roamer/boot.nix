{ config, pkgs, ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System label
  system.nixos.label = "fuck-off-glowie";

  # LUKS devices
  boot.initrd.luks.devices."luks-457633e1-c09c-4449-9c1b-2fa13b4e72a8".device = "/dev/disk/by-uuid/457633e1-c09c-4449-9c1b-2fa13b4e72a8";
  boot.initrd.luks.devices."luks-68a3659f-bf87-42a3-9bae-bed920d6bbea".device = "/dev/disk/by-uuid/68a3659f-bf87-42a3-9bae-bed920d6bbea";

  # Filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/2c3cfb65-1c46-4836-985a-44501c15fa00";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9970-8C73";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/7e8b0306-b431-496c-9f7e-21dfdc545908"; }
  ];

  # Networking
  networking.hostName = "roamer";
  networking.networkmanager.enable = true;
}
