{ pkgs, config, ... }:
{
  services.tailscale.enable = true;
  environment.systemPackages = [
    pkgs.eddie
    pkgs.i2p
    pkgs.bluez
  ];
  services.i2p.enable = true;
  hardware.bluetooth = {
  enable = true;
  };
}
