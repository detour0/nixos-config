{
  username,
  pkgs,
  ...
}: {
  # home.packages = [pkgs.gh];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "${username}";
        email = "35782618+detour0@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };
  # programs.git-worktree-switcher.enableZshIntegration = true;
}
