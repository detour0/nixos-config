{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nnvim = {
      url = "github:detour0/nnvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nurpkgs.url = "github:nix-community/NUR";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      nnvim,
      nix-vscode-extensions,
      ...
    }:
    let
      mkUser =
        username:
        {
          config,
          pkgs,
          lib,
          inputs,
          ...
        }:
        {
          _module.args = {
            inherit username;
          };
          imports = [ ./users ];
        };
    in
    {
      nixosConfigurations = {

        shaundi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/shaundi
          ];

          specialArgs = {
            inherit inputs mkUser;
            stateVersionH = "25.05";
          };

        };
      };
    };
}
