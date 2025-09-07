{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # plasma-manager = {
    #   url = "github:nix-community/plasma-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.home-manager.follows = "home-manager";
    # };
    # nnvim.url = "github.com/detour0/nnvim";
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
      # plasma-manager,
      nix-vscode-extensions,
      # nnvim,
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
      # nixpkgs-unstable.overlays = [ nnvim.overlays.default ];
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
            stateVersion = "25.05";
          };

        };
      };
    };
}
