{ config, pkgs, ... }: 
{
  imports = [
    ./networking.nix
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./sway.nix
    ./system.nix
    ./terminal.nix
    ./xdg.nix
    ./dev.nix
    ./browser.nix
  ];
}
