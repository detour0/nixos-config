{username, ...}:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    stateVersion = "24.11";
  };
  
  imports = [
    ./programs
  ];

  programs.git = {
    userName = "${username}";
    userEmail = "35782618+detour0@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
