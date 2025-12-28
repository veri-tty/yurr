{
  inputs,
  ...
}:
with inputs;
  nixpkgs.lib.nixosSystem {
    ## Setting system architecture.
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};

    ## Modules
    ##
    ## It takes an array of modules.
    modules = [
      nixos-hardware.nixosModules.framework-13-7040-amd
      home-manager.nixosModules.home-manager
      ../../modules/default.nix # Contains options and imports all relevant other modules
      ./boot.nix
      {
        # Enable modules for roamer (desktop machine)
        modules.desktop.enable = true;
        modules.desktop.gaming = true;
        modules.dev.enable = true;
        modules.pentest.enable = true;
        modules.editor.neovim = true;
        modules.virt.enable = true;
        # modules.server.enable = false; # Not a server
      }
    ];
  }
