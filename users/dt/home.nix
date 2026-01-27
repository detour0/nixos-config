{ username, ... }:
##################################################################################################################
#
# All dt's home-manager configuration
# NOT USED - for future implementation
##################################################################################################################
{
  imports = [
    ../../home
  ];

  programs.git = {
    settings = {
      user = {
        name = "${username}";
        email = "35782618+detour0@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };
}
