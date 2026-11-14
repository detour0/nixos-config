{
  nix.settings = {
    # Enable flakes and the new Nix CLI globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Additional binary caches
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-python.cachix.org"
    ];

    # Public keys for verifying cached binaries
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
    ];

    # Download buffer size: 500 MiB
    download-buffer-size = 524288000;
  };
}
