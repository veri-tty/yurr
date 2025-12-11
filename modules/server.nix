{ config, lib, pkgs, ... }:
let
  cfg = config.modules.server;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    environment.systemPackages = [
      pkgs.docker-compose
    ];
  };
}
