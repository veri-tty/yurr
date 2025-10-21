{ config, pkgs, lib, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];
  security.polkit.enable = true;
  users.users.ml = {
    isNormalUser = true;
    description = "ml";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

}
