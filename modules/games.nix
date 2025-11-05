{ inputs, config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.steam
    pkgs.wineWowPackages.waylandFull
  ];
}


