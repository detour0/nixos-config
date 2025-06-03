{ pkgs, pkgsUnstable, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgsUnstable.vscode;
    mutableExtensionsDir = true;

    profiles.default.extensions =
      (with pkgs.open-vsx; [

        # Themes
        zhuangtongfa.material-theme
        catppuccin.catppuccin-vsc

        # Javascript
        denoland.vscode-deno
        vue.volar

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
}
