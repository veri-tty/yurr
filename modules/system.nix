{ config, pkgs, lib, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];
  hardware.enableAllFirmware = true;
  security.polkit.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  users.users.ml = {
    isNormalUser = true;
    description = "ml";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

}
