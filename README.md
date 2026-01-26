Very much a work in progress

TODO:
- Create central variables for [ theme ]

Issues:

fzf:
- cd autocompletion preview into directory does not show up
-- "zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'"

Overlays:
- very unelegant solution, importing module.args/pkgsUnstable
  and the overlays from one file directly in the host config file

Gnome:
- keybindings conflict when switchen workspace
  -> <super + v>

KDE Plasma:
- workspace shortcuts need to be set manually
- splash screen is not disabled

Firefox:
- addon permissions need to be set manually
- ublock lists need to be set manually
- sync needs to be logged in manually

Vscode:
- Codeium ai plugin not working:

Dotfiles:
- Can't symlink dotfiles with hm for whatever reason

Stuff so obvious, nobody tells you:
- Run 'nix-collect-garbage -d' as 'sudo', then rebuild the system.
