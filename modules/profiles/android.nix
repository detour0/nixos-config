{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) genAttrs mkIf mkProfileOptions;
  cfg = config.profile.android;
in
{
  options.profile.android = mkProfileOptions config "android profile" { };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      android-tools
      usbutils
    ];

    users.groups.adbusers = { };
    users.users = genAttrs cfg.users (_: {
      extraGroups = [ "adbusers" ];
    });
  };
}
