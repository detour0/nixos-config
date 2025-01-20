{ username, ... }: {
  ##################################################################################################################
  #
  # All dt's home-manager configuration
  #
  ##################################################################################################################

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
