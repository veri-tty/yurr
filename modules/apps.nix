{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.signal-desktop-bin
    pkgs.spotdl
    pkgs.spotify
    pkgs.nicotine-plus
  ];
}
