{ username, ... }:
##################################################################################################################
#
# All dt's home-manager configuration
#
##################################################################################################################
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
