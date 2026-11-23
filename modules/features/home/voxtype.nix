# Voice dictation with voxtype: hold $mod+Alt+space (dotfiles/sway/config) to record, release to type the text.
# Parakeet v3 detects the language itself (25 European languages); it cannot be limited to a list.
{
  inputs,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  vox = inputs.voxtype.packages.${system};
  # Workarounds for v1.3.1's flake build, dropped once a release builds without them: it fails to link
  # (`cannot find -lsqlite3`), and a meeting-view test (tests/meeting_view_meters.rs) fails in the Nix sandbox.
  # The fixed unwrapped binary replaces the one inside upstream's wrapper.
  unwrapped = vox.voxtype-vulkan-unwrapped.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgsUnstable.sqlite ];
    doCheck = false;
  });
in
{
  imports = [ inputs.voxtype.homeManagerModules.default ];

  programs.voxtype = {
    enable = true;
    # Vulkan build: its GGUF worker runs Parakeet on the iGPU and falls back to the CPU
    package = vox.vulkan.overrideAttrs (_: {
      paths = [ unwrapped ];
    });
    engine = "parakeet";
    # Same file and checksum as `voxtype setup model` (src/setup/model.rs), but kept in the store
    model.path = pkgs.fetchurl {
      url = "https://models.voxtype.io/parakeet/parakeet-tdt-0.6b-v3-q8_0-gguf/parakeet-tdt-0.6b-v3-Q8_0.gguf";
      hash = "sha256-WFn3eUTvzY6vojpjUHMZYLK1WyID31HzGWZcgH2ALMc=";
    };
    service.enable = true;
    settings = {
      # Compositor keybindings instead of evdev, so no input group
      hotkey.enabled = false;
      audio = {
        max_duration_secs = 600; # long dictations; Parakeet splits them into windows
        duck_media = true; # lower playing media while recording (default 34% amplitude), restored on stop
        # Bluetooth headsets switch to headset mode when the mic opens, which pauses players anyway;
        # voxtype pauses them first and resumes them when recording stops
        pause_media = false;
      };
      # No notification with the text of a successful dictation; failures still notify
      output.notification.on_transcription = false;
      parakeet.threads = 4; # physical cores
      # Only used with engine = "whisper": detection limited to these, English first
      whisper.language = [
        "en"
        "de"
        "es"
      ];
    };
  };
}
