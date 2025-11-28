{ config, pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./nix.nix
    ./apps.nix
    ./locale.nix
    ./pen.nix
    ./sway.nix
    ./games.nix
    ./system.nix
    ./terminal.nix
    ./xdg.nix
    ./dev.nix
    ./browser.nix
    ./nixvim.nix
  ];
}
