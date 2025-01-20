{ username, config,  ... }: 
  ##################################################################################################################
  #
  # All dt's home-manager configuration
  #
  ##################################################################################################################
let
  nvimPath = "${config.home.homeDirectory}/nix-config/user/${username}/dotfiles/nvim";
  vscodePath = "${config.home.homeDirectory}/nix-config/user/${username}/dotfiles/vscode";
in
{
  xdg.configFile {
    "nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink nvimPath;
      recursive = true;
    };
    "vscode" = {
      source = config.lib.file.mkOutOfStoreSymlink vscodePath;
      recursive = true;
    };
  };
 
  imports = [
    ../../home
    ../../home/programs
  ];

  programs.git = {
    userName = "${username}";
    userEmail = "john_does@aol.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
