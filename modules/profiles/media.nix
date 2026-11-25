{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:

let
  inherit (lib) mkIf mkProfileHome mkProfileOptions;
  cfg = config.profile.media;

  # Tauon's default keymap with a few changes. Tauon only reads input.txt (no defaults behind it),
  # so start from the template the package ships and swap lines, failing the build if one is gone.
  tauonKeymap = pkgs.runCommand "tauon-input.txt" { } ''
    template=$(find ${pkgs.tauon} -path '*/tauon/templates/input.txt' | head -n1)
    cat > drop <<'EOF'
    random-track-start /
    quick-find \
    quick-find F Ctrl
    EOF
    while read -r line; do
      grep -qxF "$line" "$template" || { echo "tauon template lacks: $line" >&2; exit 1; }
    done < drop
    grep -vxFf drop "$template" > $out
    cat >> $out <<'EOF'

    # nixos-config overrides
    quick-find /
    random-track-start \
    global-search F Ctrl
    cycle-playlist-right J Ctrl
    cycle-playlist-left K Ctrl
    EOF
  '';
in
{
  options.profile.media = mkProfileOptions config "media profile" { };

  config = mkIf cfg.enable (
    mkProfileHome cfg {
      home.packages = with pkgs; [
        scrcpy
        obs-studio
        yt-dlp
        mpv
        # Jellyfin music client (unstable: 0.22, Wayland built in)
        pkgsUnstable.supersonic
        # keyboard-friendlier Jellyfin client, native (SDL)
        tauon
      ];

      # Tauon copies its template here on first start; force replaces that copy.
      xdg.dataFile."TauonMusicBox/input.txt" = {
        source = tauonKeymap;
        force = true;
      };
    }
  );
}
