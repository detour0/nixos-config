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
      plasma-manager,
      nix-vscode-extensions,
      ...
    }:
    {
      nixosConfigurations = {
        desktop-NixOs =
          let
            username = "dt";
          in
          nixpkgs.lib.nixosSystem {

            specialArgs = { inherit username inputs; };
            system = "x86_64-linux";

            modules = [
              sops-nix.nixosModules.sops
              ./hosts/desktop-NixOs
              ./overlays
              ./modules/extrargs.nix
              ./modules/tws.nix

              home-manager.nixosModules.home-manager
              (
                { config, ... }:
                {
                  # Use a function to access `config`
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    # sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                    extraSpecialArgs = {
                      inherit username inputs;
                      pkgsUnstable = config._module.args.pkgsUnstable; # Reference from module args
                    };
                    users.${username} = import ./users/${username}/home.nix;
                    backupFileExtension = "backup";
                  };
                }
              )
            ];
          };

      };
    };
}
