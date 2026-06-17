{
  description = "NixOS Configuration — Fujitsu Q958 Homelab Server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, impermanence, home-manager, hermes-agent, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      grok-cli = pkgs.callPackage ./packages/grok-cli { };
    in
    {
      packages.${system}.grok-cli = grok-cli;

      nixosConfigurations = {
        q958 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self grok-cli; };
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            ./machines/q958/default.nix
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            hermes-agent.nixosModules.default
          ];
        };
      };
    };
}