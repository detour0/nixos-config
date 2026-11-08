Very much a work in progress

DOC:

- SSH:
  - Admin clients:
    - Clients only
    - Main user has one key each for decrypting all sops files and server root deployment,
      github read/write, connecting to server-user account.
    - Host-ssh key is for sops decrypting only
  - Server:
    - Only key for accessing private github 'Nix-secrets' repo.
    - Public admin keys are written in authorized key files for root and user.

- Stuff so obvious, nobody tells you:
  - Run 'nix-collect-garbage -d' as 'sudo', then rebuild the system to remove previous generations
    from the bootloader

TODO:

- Create central variables for [ theme desktop-environment ]
- Main output variable (kanshi) | show waybar, focus after wr switch
- configure rofi, integrate cliphist
  - exclude passwords from history

Issues:

-     # eza as a drop-in replacement for ls
      # Something is implicitly generating an ls alias
      unalias ls 2>/dev/null
      ls() {
        eza --icons=auto --color=auto "$@"
      }

Theming:

- setting a cursor package does nothing

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
