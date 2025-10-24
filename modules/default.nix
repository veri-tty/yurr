{ config, pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./nix.nix
    ./apps.nix
    ./boot.nix
    ./locale.nix
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
