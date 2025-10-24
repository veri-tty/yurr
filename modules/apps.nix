{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.signal-desktop-bin
    pkgs.spotify
  ];
}
