{ pkgs, ... }:
{
    programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;

        extensions = with pkgs.open-vsx; [

            # Themes
            zhuangtongfa.material-theme

            # Javascript
            denoland.vscode-deno

            # Python
            ms-python.python
            ms-toolsai.jupyter
            ms-python.debugpy
            charliermarsh.ruff


            # Helpers
            asvetliakov.vscode-neovim
            redhat.vscode-yaml
            esbenp.prettier-vscode
            jnoortheen.nix-ide
        ];
    };
}
