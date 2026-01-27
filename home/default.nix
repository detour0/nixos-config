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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
