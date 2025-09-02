{ config, username, ... }
{
    home-manager.nixosModules.home-manager
    (
        { config, username, ... }:
        {
            # Use a function to access `config`
            home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
            inherit username inputs;
            pkgsUnstable = config._module.args.pkgsUnstable; # Reference from module args
            };
            users.${username} = import ./users/${username}/home.nix;
            backupFileExtension = "backup";
            };
        }
    )
    home-manager.users.${username} = import ../../../../home/${username}/${config.networking.hostName}.nix;
}