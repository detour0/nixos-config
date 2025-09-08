{
  username,
  inputs,
  stateVersionH,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (
      {
        config,
        username,
        inputs,
        ...
      }:
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit username inputs stateVersionH;
            pkgsUnstable = config._module.args.pkgsUnstable;
          };
          users.${username} = import ../home; # import ../home/${username}/${config.networking.hostName}.nix;
          backupFileExtension = "backup";
        };
      }
    )
  ];
}
