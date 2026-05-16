{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nurpkgs.url = "github:nix-community/NUR";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      sops-nix,
      deploy-rs,
      ...
    }:
    let
      myLib = nixpkgs.lib.extend (selfLib: superLib: (import ./lib { lib = selfLib; }));
    in
    {
      nixosConfigurations = {

        shaundi = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/shaundi
            sops-nix.nixosModules.sops
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];

          specialArgs = {
            inherit inputs;
            lib = myLib;
            # Do not change from 25-05!
            stateVersionH = "25.05";
          };
        };

        schiggi = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/schiggi
            sops-nix.nixosModules.sops
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
          specialArgs = {
            inherit inputs;
            lib = myLib;
            stateVersionH = "25.11";
          };
        };
      };

      deploy.nodes = {
        schiggi = {
          hostname = "192.168.178.117";
          profiles.system = {
            sshUser = "root";
            remoteBuild = true;
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.schiggi;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
