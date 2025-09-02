  {
    import = [
        ./locale.nix
        ./settings.nix
        ./fonts.nix
        ./nameserver.nix
    ]

    # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  }