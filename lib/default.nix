{ lib }:
let
  inherit (lib)
    attrNames
    genAttrs
    mkEnableOption
    mkOption
    types
    ;
in
{
  # The options every profile has, plus its own
  mkProfileOptions =
    config: description: extraOptions:
    {
      enable = mkEnableOption description;
      users = mkOption {
        type = types.listOf types.str;
        default = attrNames config.myUsers;
        defaultText = "every user in myUsers";
        description = "Users the profile applies to.";
      };
    }
    // extraOptions;

  # A home-manager module for every user of a profile
  mkProfileHome = cfg: module: {
    home-manager.users = genAttrs cfg.users (_: module);
  };
}
