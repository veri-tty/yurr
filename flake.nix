{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    schizofox.url = "github:schizofox/schizofox";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-hardware,
    ...
  } @ inputs: let
    globals = {
      user = "ml";
      stateVers = "24.11";
    };

    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    specialArgs = {inherit inputs;}; # pass the inputs into the configuration module
  in rec {
    ## System configurations
    nixosConfigurations = {
      roamer = import ./roamer.nix {inherit inputs globals nixpkgs nixos-hardware;};
    };

    ## Home configurations
    homeConfigurations = {
      roamer = nixosConfigurations.roamer.config.home-manager.users.ml.home;
    };
  };
}
