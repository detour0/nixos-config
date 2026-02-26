{ username, stateVersionH, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "${stateVersionH}";
  };

  imports = [
    ./programs
  ];

<<<<<<< HEAD
=======
  programs.git = {
    settings = {
      user = {
        name = "${username}";
        email = "35782618+detour0@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

>>>>>>> sway
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
