{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.role.desktop;
in
{
  imports = [ ../features/sway.nix ];

  options.role.desktop = mkRoleOptions "desktop role" {
    environment = mkOption {
      type = types.enum [
        "sway"
        "none"
      ];
      default = "sway";
    };
    emulator = mkOption {
      type = types.enum [ "wezterm" ];
      default = "wezterm";
    };
    browsers = mkOption {
      type = types.listOf (
        types.enum [
          "firefox"
          "librewolf"
          "brave"
        ]
      );
      default = [
        "firefox"
        "brave"
      ];
    };
    office = mkEnableOption "libre office with language packs";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      features.sway.enable = mkIf (cfg.environment == "sway") true;
    }

    (mkRoleHome config "dev" (user: {
      imports = flatten [
        (optional (elem "firefox" cfg.browsers) ../features/home/firefox)
        (optional (elem "brave" cfg.browsers) ../features/home/brave.nix)
        (optional (cfg.emulator == "wezterm") ../features/home/wezterm.nix)
      ];

      home.packages =
        with pkgs;
        [
          megasync
          keepassxc
          obsidian
        ]
        ++ optionals cfg.office [
          libreoffice-fresh
          hunspell
          hunspellDicts.de_DE
          hunspellDicts.en_US
        ];

    }))
  ]);
}
