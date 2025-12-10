{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  console.keyMap = "de";

  nixpkgs.config.allowUnfree = true;
  home-manager.backupFileExtension = "delme";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    git
    unzip
    wget
    curl
    unrar
    ripgrep
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      glibc
      zlib
      libGL
      libglvnd
      vulkan-loader
      alsa-lib
      libpulseaudio
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      xorg.libXinerama
    ];
  };

  hardware.enableAllFirmware = true;
  security.polkit.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  users.users.ml = {
    isNormalUser = true;
    description = "ml";
    extraGroups = [ "networkmanager" "kvm" "wheel" "docker" "libvirt" "video" ];
  };

  networking.networkmanager.enable = true;
  services.tailscale.enable = true;
  hardware.bluetooth.enable = true;

  home-manager.users.ml.home.stateVersion = "24.11";
  system.stateVersion = "24.11";
}
