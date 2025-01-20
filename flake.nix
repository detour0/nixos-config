{
  description = "Some day... i'll get this working";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nurpkgs.url = "github:nix-community/NUR";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    plasma-manager,
    nix-vscode-extensions,
    ...
  }: {
    nixosConfigurations = {
      desktop-NixOs =
      let
        username = "dt";
        specialArgs = {inherit username inputs;};
      in
        nixpkgs.lib.nixosSystem {

          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            ./hosts/desktop-NixOs
            ./overlays

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              home-manager.extraSpecialArgs = { inherit username inputs; };
              home-manager.users.${username} = import ./users/${username}/home.nix;
              home-manager.backupFileExtension = "backup";
            }
          ];
        };

    };
  };
}
