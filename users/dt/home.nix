{ username, ... }:
##################################################################################################################
#
# All dt's home-manager configuration
#
##################################################################################################################
# Does create the symlink, but with invalid target
# let
#   nvimPath = "${config.home.homeDirectory}/nix-config/dotfiles/nvim-init.lua";
#   vscodeSettingsPath = "${config.home.homeDirectory}/dotfiles/vscode/settings.json";
# in

# {
#   home.file = {
#     ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
#     ".config/Code/User/settings.json" = {
#       source = config.lib.file.mkOutOfStoreSymlink vscodeSettingsPath;
#       force = true; # Overrite existing files
#     };
#   };
{
  imports = [
    ../../home
    ../../home/programs
  ];

  programs.git = {
    userName = "${username}";
    userEmail = "35782618+detour0@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
