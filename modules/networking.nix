{ pkgs, config, ... }:
{
  networking.hosts = {
  #htb
  "10.129.45.239" = ["thetoppers.htb"];
  "10.129.95.234" = ["unika.htb"];
  };
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  environment.systemPackages = [
    pkgs.eddie
    pkgs.yggstack
    pkgs.wireguard-tools
    pkgs.i2p
    pkgs.bluez
    pkgs.networkmanagerapplet
  ];
  #services.i2p.enable = false;
  hardware.bluetooth = {
  enable = true;
  };
}
