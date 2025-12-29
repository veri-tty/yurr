{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
  };

  outputs = {
    nixpkgs,
    nixos-hardware,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    specialArgs = {inherit inputs;}; # pass the inputs into the configuration module
  in rec {
    ## System configurations
    nixosConfigurations = {
      roamer = import ./machines/roamer/roamer.nix {inherit inputs nixpkgs nixos-hardware;};
      yalt = import ./machines/yalt/yalt.nix {inherit inputs nixpkgs nixos-hardware;};
    };

    ## Home configurations
    homeConfigurations = {
      yalt = nixosConfigurations.yalt.config.home-manager.users.ml.home;
      roamer = nixosConfigurations.roamer.config.home-manager.users.ml.home;
    };
  };
}
