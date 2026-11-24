{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    elem
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkProfileHome
    mkProfileOptions
    optional
    optionals
    types
    ;
  cfg = config.profile.desktop;
in
{
  imports = [ ../features/sway.nix ];

  options.profile.desktop = mkProfileOptions config "desktop profile" {
    environment = mkOption {
      type = types.enum [
        "sway"
        "None"
      ];
      default = "sway";
    };
    emulators = mkOption {
      type = types.listOf (
        types.enum [
          "wezterm"
          "ghostty"
        ]
      );
      default = [ "wezterm" ];
      description = "Terminal emulators to install. sway's $term stays wezterm.";
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
    dictation = mkEnableOption "voxtype voice dictation (hold $mod+Alt+space in sway)";
    agent = mkOption {
      type = types.enum [
        "hermes"
        "None"
      ];
      default = "None";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      features.sway.enable = cfg.environment == "sway";
      environment.systemPackages = [ pkgs.usbutils ];
    }

    (mkProfileHome cfg {
      imports =
        optional (elem "firefox" cfg.browsers) ../features/home/firefox
        ++ optional (elem "brave" cfg.browsers) ../features/home/brave.nix
        ++ optional (elem "wezterm" cfg.emulators) ../features/home/wezterm.nix
        ++ optional (elem "ghostty" cfg.emulators) ../features/home/ghostty.nix
        ++ optional cfg.dictation ../features/home/voxtype.nix
        ++ optional (cfg.agent == "hermes") {
          imports = [ inputs.hermes-agent.homeManagerModules.default ];
          programs.hermes-agent = {
            enable = true;
            desktop.enable = true;
          };
        };

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
    })
  ]);
}
