{
  config,
  lib,
  ...
}:
let
  cfg = config.features.pipewire;
in
{
  options.features.pipewire.enable = lib.mkEnableOption "pipewire";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };
}
