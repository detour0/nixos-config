{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.file.".config/nvim/init.lua".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink ./../../dotfiles/nvim/init.lua
  );
  home.file.".config/nvim/lua/code_config/vscode_keymap.lua".source = lib.mkForce (
    config.lib.file.mkOutOfStoreSymlink ./../../dotfiles/nvim/lua/code_config/vscode_keymap.lua
  );
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      comment-nvim
      # hop-nvim
    ];
  };
}
