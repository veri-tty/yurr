{ config, pkgs, ... }: 
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./sway.nix
    ./system.nix
    ./terminal.nix
    ./xdg.nix
  ];
}
