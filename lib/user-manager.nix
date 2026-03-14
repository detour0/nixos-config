{
  config,
  lib,
  pkgs,
  inputs,
  stateVersionH,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    mapAttrs
    filterAttrs
    ;

  # Grab all users defined under our custom option
  cfg = config.myUsers;

  # Filter to only users where 'enable = true'
  activeUsers = filterAttrs (name: userCfg: userCfg.enable) cfg;

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options.myUsers = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          enable = mkEnableOption "this user";
          name = mkOption {
            type = types.str;
            default = "";
          };
          description = mkOption {
            type = types.str;
            default = "";
          };
          extraGroups = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };

          # Metadata that roles or HM can use later
          gitName = mkOption {
            type = types.str;
            default = "";
          };
          gitEmail = mkOption {
            type = types.str;
            default = "";
          };
        };
      }
    );
    default = { };
  };

  # 2. APPLY THE DATA
  config = mkIf (activeUsers != { }) {

    # A. System-wide Home Manager Settings (Applied exactly ONCE per system)
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = {
        inherit inputs stateVersionH pkgsUnstable;
      };
    };

    _module.args = {
      inherit pkgsUnstable;
    };

    # B. Setup the OS System Users dynamically
    users.users = mapAttrs (username: userCfg: {
      isNormalUser = true;
      # Use inherit for these because names match
      inherit (userCfg) description extraGroups;
      initialPassword = "";
    }) activeUsers;

    # C. Setup the Home Manager base dynamically
    home-manager.users = mapAttrs (username: userCfg: {
      home.stateVersion = stateVersionH;
      # programs.home-manager.enable = true;

      # Use the user's data to configure their basics
      programs.git = mkIf (userCfg.gitName != "") {
        enable = true;
        settings = {
          user = {
            name = userCfg.gitName;
            email = userCfg.gitEmail;
          };
          init.defaultBranch = "main";
        };
      };
      # };
    }) activeUsers;

  };
}
