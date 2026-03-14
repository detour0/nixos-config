{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad = {
      url = "github:nix-community/nix4nvchad";
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
      sops-nix,
      ...
    }:
    let
      myLib = nixpkgs.lib.extend (selfLib: superLib: (import ./lib { lib = selfLib; }));
    in
    {
      nixosConfigurations = {

        # shaundi = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   modules = [
        #     ./hosts/shaundi
        #   ];
        #
        #   specialArgs = {
        #     inherit inputs mkUser;
        #     # Do not change from 25-05!
        #     stateVersionH = "25.05";
        #   };
        # };

        schiggi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/schiggi
          ];
          specialArgs = {
            inherit inputs;
            lib = myLib;
            stateVersionH = "25.11";
          };
        };

      };
    };
}
