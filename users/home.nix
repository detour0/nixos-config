{
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
            inherit (config._module.args) pkgsUnstable;
          };
          users.${username} = import ../home;
          backupFileExtension = "bak";
        };
      }
    )
  ];
}
