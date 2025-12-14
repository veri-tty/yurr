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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNVd0Qb5XiQF7WMOoBPhOuO8ttoFPZmqiikNLEar9gy"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOJZEjixfR08o2MsqFto5Vs9Cfo2Gwsjd5WvR9dcuvAYXiT7qTRTu507IXwK3KqdQoY5RMLjKnSHCErRceEhGm92fo4I/+l0DgWuo6w1YRfquK2cKg/BcLZO3EKTJb5YVREIAD/5X42wPmiQyVExzPidpAwKdYHNGa99HcG4JUO5S+l6aLUk/0u7NL4af5tAYYVLT4AfVXAjjuVylB63EtbfLWQGTbLuwuXI9VxUwboyRu/mVaKWCXxh1VC0kfsfqsMSvIAHo1vEwUHLdZ7m6TyCiFbvtE7bqPJwBYU1/i+BSbktJTZLlSws02f2pl65mnImG5MSe+iFeqQTKP0ApeRRJ6CTqSYbI0l8kDJ5xAPLM7GhAR0xJ1fpLts0mFgyBcZAgT3Qb1RFNQWfgIsUdB/azON8p7Xud7VXvssK35JZRjxuLUgjMTRbZXMIGiFwkr+E1Qn/e2MIddjW+Sy7fg7ywVnVBFTa+WljhvLCl3fidb54uJYSyMQiCX73Ut7AjjJfR2HiwGwscKWxD3dVCb8SdBvvmFglc/IrAyBozBthSJzU1/w/wlBO4R7RvX1ixIl8NpIgGEx2GCYbbxYcCNgiZDgLVisPR8CAcKruwkoscd1jHEjdIfHrxE0aSUvA5QoE54H5DTIavbzowFdUnJn8fKpHL00YgHg1wLwhISzw== ml@roamer"
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
