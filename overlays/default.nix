{
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
      inputs.nix-vscode-extensions.overlays.default
    ];
    # Configure your nixpkgs instance
}
