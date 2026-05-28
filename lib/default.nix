{ lib }:
let
  inherit (lib)
    types
    mkOption
    mkIf
    genAttrs
    mkEnableOption
    ;
in
{
  # Helper to generate the common profile schema
  mkProfileOptions =
    description: extraOptions:
    {
      enable = mkEnableOption description;
      users = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    }
    // extraOptions; # Merge common options with profile-specific ones

  mkProfileHome =
    config: profileName: homeConfig:
    mkIf config.profile.${profileName}.enable {
      home-manager.users = genAttrs config.profile.${profileName}.users homeConfig;
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
