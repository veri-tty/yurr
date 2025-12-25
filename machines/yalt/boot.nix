{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader configuration
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    devices = ["/dev/nvme0n1"];
    efiSupport = true;
  };

  # System label
  system.nixos.label = "laintard";

  # Kernel configuration
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "ip=dhcp" ];

  # Initrd with remote LUKS unlock
  boot.initrd = {
    availableKernelModules = [ "e1000e" "vmd" "xhci_pci" "ahci" "nvme" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2425;
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDk+w+nz2OSjtZ9qFzZL0m74xLflL/jjvIPdx9bBLsiJcqQPxNYYhWOMUDKzBjl6sWKwKQq9/m1gA7Y5yNghS67wXj2lkvSQQr27RWCwlxUQfGgQi2sRhRVNkHq1GPJBeX3D/aaEkQG+Y+RZTpIXOMDgEjhrpCgKBnc2IJuKaOppjw2ePiyu4w5tE6OXze8HMT+1KEsM+7NJtWZyJbNzy+bCtv5v84Ho6sbUw4p71SnIF92OK80Oe1I9puWtfr9wjK+sRRcGLMGTjxoo4ZVnlwJGJ6aKixvkiJEOIzTYgjk17dQDUrsOUTsHNSJaFpa46laKw/XjdFgbzNw5td2mISqY4Azppo5ynOlcdeEzFiFgV9hzBAOe7kuZxOkEWwLXr/8/7SNi0VbZnn/gQIJJp8G/tF6cxu9iVBWl7EKYlPiDveq++vY6I74FZJbMR1Ge8wnSEWTHIFKoJe3hJDiw2PYPCorUBtuwQ/jS7DaT9dVp6liN+iOT06jhtXdYASQzic= ml@roamer
"
        ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };


  # Networking
  networking.hostName = "yalt";
  networking.networkmanager.enable = true;

  # Hardware
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
