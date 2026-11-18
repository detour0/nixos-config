{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkIf
    mkOption
    types
    ;

  cfg = config.myUsers;
  inherit (config.system) stateVersion;

  str = mkOption {
    type = types.str;
    default = "";
  };

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Importing users/<name>.nix is what creates a user: system account plus home-manager profile
  options.myUsers = mkOption {
    default = { };
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            # The attribute name, for referring to a user in host files: users = [ dt.name ]
            name = mkOption {
              type = types.str;
              default = name;
              readOnly = true;
            };
            shell = mkOption {
              type = types.package;
              default = pkgs.bash;
            };
            hashedPasswordFile = str;
            description = str;
            extraGroups = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            gitName = str;
            gitEmail = str;
          };
        }
      )
    );
  };

  config = {
    # pkgsUnstable as a module argument, in NixOS modules and (below) in home-manager modules
    _module.args = { inherit pkgsUnstable; };

    users.mutableUsers = false;
    users.users = mapAttrs (_: user: {
      isNormalUser = true;
      inherit (user)
        shell
        hashedPasswordFile
        description
        extraGroups
        ;
    }) cfg;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = { inherit inputs pkgsUnstable; };

      users = mapAttrs (
        _: user:
        { config, ... }:
        {
          # Both are pinned per host and never change
          home.stateVersion = stateVersion;

          # Files in dotfiles/, by their path in it. Modules use `source`; `live` switches them all:
          #   false: store copies. Edits need a rebuild, and the repo can be anywhere.
          #   true: symlinks into `dir`. Edits apply without a rebuild, and the repo must stay at `dir`.
          #         `nixos-rebuild build-vm` cannot follow these.
          lib.dotfiles = rec {
            live = false;
            dir = "${config.home.homeDirectory}/workspace/nixos-config/dotfiles";
            link = path: config.lib.file.mkOutOfStoreSymlink "${dir}/${path}";
            store = path: ../dotfiles + "/${path}";
            source = if live then link else store;
          };

          programs.git = mkIf (user.gitName != "") {
            enable = true;
            settings = {
              user = {
                name = user.gitName;
                email = user.gitEmail;
              };
              init.defaultBranch = "main";
            };
          };
        }
      ) cfg;
    };
  };
}
