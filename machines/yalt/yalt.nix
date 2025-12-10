{
  inputs,
  ...
}:
with inputs;
  nixpkgs.lib.nixosSystem {
    ## Setting system architecture.
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      ./configuration.nix
    ];
}