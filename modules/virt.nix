{ pkgs, lib, inputs, config, ... }:
let
  cfg = config.modules.virt;
in
{
  config =  lib.mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ "ml"];
  };
}

