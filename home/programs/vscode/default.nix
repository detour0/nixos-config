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

            # Productivity
            asvetliakov.vscode-neovim
            vspacecode.whichkey

            # miscellaneous
            redhat.vscode-yaml
            esbenp.prettier-vscode
            ms-azuretools.vscode-docker

            # LSPs
            jnoortheen.nix-ide
        ];
    };
}
