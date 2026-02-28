Very much a work in progress

TODO:
- Create central variables for [ theme desktop-environment ]
- atm all users get assigned the same git-email
- Main output variable (kanshi) | show waybar, focus after wr switch
- configure rofi, integrate cliphist

Issues:

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

Stuff so obvious, nobody tells you:
- Run 'nix-collect-garbage -d' as 'sudo', then rebuild the system.
