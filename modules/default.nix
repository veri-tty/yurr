{ config, lib, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./sandbox.nix
    ./core.nix
    ./terminal.nix
    ./desktop.nix
    ./dev.nix
    ./opencode.nix
    ./pentest.nix
    ./server.nix
    ./nixvim.nix
    ./claude-sandbox.nix
  ];
}
