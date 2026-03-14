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

  # Helper to link a System Feature to a Home Manager Module
  # It injects the specific user's settings into the module's scope
  mkFeatureBridge =
    path:
    (
      {
        config,
        osConfig,
        ...
      }:
      {
        imports = [ path ];

        # We define a local 'config' extension that modules can use
        # to find their data without typing the whole osConfig path
        _module.args.userSettings = osConfig.myUsers.${config.home.username} or { };
      }
    );
}
