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
    localSystem = pkgs.stdenv.hostPlatform;
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
          shell = mkOption {
            type = types.package;
            default = pkgs.bash;
          };
          hashedPasswordFile = mkOption {
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

          # Metadata that profiles or HM can use later
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
      # Makes pkgsUnstable available inside HM
      extraSpecialArgs = {
        inherit inputs stateVersionH pkgsUnstable;
      };
    };

    # Makes pkgsUnstable available in system-level modules
    _module.args = {
      inherit pkgsUnstable;
    };

    # B. Setup the OS System Users dynamically
    users.mutableUsers = false;
    users.users = mapAttrs (username: userCfg: {
      isNormalUser = true;
      inherit (userCfg)
        shell
        hashedPasswordFile
        description
        extraGroups
        ;
    }) activeUsers;

    # C. Setup the Home Manager base dynamically
    home-manager.users = mapAttrs (username: userCfg: {
      home.stateVersion = stateVersionH;
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
