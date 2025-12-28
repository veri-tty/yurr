{ config, lib, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./virt.nix
    ./core.nix
    ./terminal.nix
    ./desktop.nix
    ./dev.nix
    ./opencode.nix
    ./pentest.nix
    ./server.nix
    ./nixvim.nix
  ];
}
