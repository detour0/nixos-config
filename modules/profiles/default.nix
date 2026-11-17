# Every profile; each one does nothing until its `profile.<name>.enable` is set
{
  imports = [
    ./agents.nix
    ./android.nix
    ./core.nix
    ./desktop.nix
    ./dev.nix
    ./game.nix
    ./media.nix
    ./monitor.nix
    ./peripherals.nix
  ];
}
