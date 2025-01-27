{ pkgs, inputs,lib, ... }:
{
    extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
      ublock-origin
      privacy-badger
      vimium
      darkreader
      unpaywall
      tabliss
      # languagetool Unfree licence error despite: allowUnfree in system.nix
      link-cleaner
      # auto-accepts cookies, use only with privacy-badger & ublock-origin
      istilldontcareaboutcookies
    ];
}
