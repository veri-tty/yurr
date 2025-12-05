{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.signal-desktop-bin
    pkgs.vlc
    pkgs.qbittorrent
    pkgs.waydroid
    pkgs.feather
    pkgs.tor-browser
    pkgs.electrum
    pkgs.wasistlos
    pkgs.spotdl
    pkgs.spotify
    pkgs.nicotine-plus
  ];
}
