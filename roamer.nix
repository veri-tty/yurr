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

    ## Modules
    ##
    ## It takes an array of modules.
    modules = [
      nixos-hardware.nixosModules.framework-13-7040-amd
      home-manager.nixosModules.home-manager
      ./modules/default.nix # Contains options and imports all relevant other modules
    ];
  }
