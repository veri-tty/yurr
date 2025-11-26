{
  inputs,
  globals,
  ...
}:
with inputs;
  nixpkgs.lib.nixosSystem {
    ## Setting system architecture.
    system = "x86_64-linux";
    specialArgs = {inherit inputs nur;};
    boot.kernelParams = [ "ip=dhcp" ];
    boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2223;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNVd0Qb5XiQF7WMOoBPhOuO8ttoFPZmqiikNLEar9gy"
        ];
        hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
        shell = "/bin/cryptsetup-askpass";
      };
    };
  };
  networking.networkmanager.enable = true; # you can use something else, it's up to you
  time.timeZone = "Europe/Berlin"; # Replace with your timezone
  environment.systemPackages = with pkgs; [
     vim
  ];
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  }; # Obv let's enable flakes by default
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # allow root login via ssh only for the first boot, after that you should disable it
      PasswordAuthentication = true; # allow password authentication for the first boot, create a user with an authorized key and disable it
    };
  };

    ## Modules
    networking.hostName = "yalt"; # Define your hostname.
    boot.loader.systemd-boot.enable = true;
    system.nixos.label = "MangoDiddybludOS3000";
    modules = [
      nixos-hardware.nixosModules.framework-13-7040-amd
      home-manager.nixosModules.home-manager
      ../../modules/default.nix
      ./disko.nix
    ];


    
  }
