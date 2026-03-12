{ lib, config, ... }:

with lib;

{
  # The role type: every role has these options
  options.role = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          enable = mkEnableOption "this role";
          users = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Users who get this role's features";
          };
        };
      }
    );
    default = { };
    description = "Role assignments for this host";
  };

  # Helper for role modules: apply home config to role's users
  _module.args.mkRoleHomes =
    roleName: homeConfig:
    mkIf config.role.${roleName}.enable {
      home-manager.users = genAttrs config.role.${roleName}.users homeConfig;
    };
}
