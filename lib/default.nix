{ lib }:
{
  # Helper to generate the common role schema
  mkRoleOptions =
    description: extraOptions:
    {
      enable = lib.mkEnableOption description;
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    }
    // extraOptions; # Merge common options with role-specific ones

  mkRoleHome =
    config: roleName: homeConfig:
    lib.mkIf config.role.${roleName}.enable {
      home-manager.users = lib.genAttrs config.role.${roleName}.users homeConfig;
    };
}
