{ lib }:
{
  # Helper to generate the common profile schema
  mkProfileOptions =
    description: extraOptions:
    {
      enable = lib.mkEnableOption description;
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    }
    // extraOptions; # Merge common options with profile-specific ones

  mkProfileHome =
    config: profileName: homeConfig:
    lib.mkIf config.profile.${profileName}.enable {
      home-manager.users = lib.genAttrs config.profile.${profileName}.users homeConfig;
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
