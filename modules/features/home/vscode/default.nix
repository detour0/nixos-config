{
  pkgs,
  lib,
  config,
  pkgsUnstable,
  ...
}:
{
  home.file.".config/Code/User/settings.json".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink ./../../../dotfiles/Code/User/settings.json
  );
  home.file.".config/Code/User/keybindings.json".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink ../../../dotfiles/Code/User/keybindings.json
  );
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;
    #'true' causes vscode to restrict extensions to certain profiles, requiring manual enabling
    mutableExtensionsDir = false;

    profiles.default = {

      # userSettings = builtins.toString ../../../dotfiles/Code/User/settings.json;
      # keybindings = builtins.toString ../../../dotfiles/Code/User/keybindings.json;

      extensions =
        (with pkgs.open-vsx; [

          # Themes
          zhuangtongfa.material-theme
          catppuccin.catppuccin-vsc

          # Javascript
          denoland.vscode-deno

          # Python
          ms-python.python
          ms-toolsai.jupyter
          ms-python.debugpy
          charliermarsh.ruff

          # Productivity
          asvetliakov.vscode-neovim
          vspacecode.whichkey

          # miscellaneous
          redhat.vscode-yaml
          esbenp.prettier-vscode
          ms-azuretools.vscode-containers

          # LSPs
          jnoortheen.nix-ide
        ])
        ++ (with pkgs.vscode-extensions; [
          ms-python.vscode-pylance
          ms-vscode-remote.remote-containers
        ]);
    };
  };
}
