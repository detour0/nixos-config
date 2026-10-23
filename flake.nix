{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets.url = "git+ssh://git@github.com/detour0/nix-secrets.git";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nurpkgs.url = "github:nix-community/NUR";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      sops-nix,
      deploy-rs,
      disko,
      hermes-agent,
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
            hermes-agent.nixosModules.default
            sops-nix.nixosModules.sops
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
          specialArgs = {
            inherit inputs;
            lib = myLib;
            # Do not change from 25-11!
            stateVersionH = "25.11";
          };
        };

        digda = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/digda
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            { nixpkgs.hostPlatform = "x86_64-linux"; }
          ];
          specialArgs = {
            inherit inputs;
            lib = myLib;
            # Do not change from 26.05!
            stateVersionH = "26.05";
          };
        };
      };

      deploy.nodes = {
        schiggi = {
          hostname = inputs.nix-secrets.networking.schiggi.netbirdIp;
          profiles.system = {
            sshUser = "root";
            remoteBuild = true;
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.schiggi;
          };
        };
        digda = {
          hostname = "45.131.109.61";
          profiles.system = {
            sshUser = "root";
            remoteBuild = false;
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.digda;
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
