{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.profile.android;
in
{
  options.profile.android = mkProfileOptions "android profile" { };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        android-tools
        usbutils
      ];
      users.groups.adbusers = { };
    }
    {
      users.users = genAttrs cfg.users (user: {
        extraGroups = [ "adbusers" ];
      });
    }
  ]);
}
