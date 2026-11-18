# Working in this repo

Flake-based NixOS config with home-manager as a NixOS module (nixpkgs 26.05, plus an unstable input).

| Host      | Role                                         | User   | Applied by               |
| --------- | -------------------------------------------- | ------ | ------------------------ |
| `shaundi` | sway desktop; the machine this repo lives on | dt     | local `nixos-rebuild`    |
| `schiggi` | headless server                              | dt     | deploy-rs (remote build) |
| `digda`   | headless edge VPS (BIOS/GRUB, disko)         | keeper | deploy-rs (local build)  |

## Rules

- **Never apply changes yourself.** No `nixos-rebuild switch|test|boot`, no `deploy`, no `sudo`. Build to
  verify, then tell the user what to run.
- Never change `system.stateVersion`; it is pinned per host, and home-manager's `home.stateVersion` follows it.
- Never inline secrets, IPs or keys, and never print decrypted values. They come from
  `inputs.nix-secrets.<...>` (plain values) or sops (`config.sops.secrets.<name>.path`).
- `nix flake update [input]` only when asked.
- Commit only when asked. Style: `feat: …` / `fix: …`, lowercase, comma-separated summary.
- `git add` new files before building: a flake only sees git-tracked files, so an untracked file "does not exist".

## Layout

- `flake.nix`: inputs, one explicit `nixosConfigurations` entry per host, `deploy.nodes`.
- `hosts/<name>/default.nix`: imports and option values only. No logic here; put it in a profile or feature.
  Every host imports `modules/system`, `modules/profiles`, its sops role and its `users/*.nix`.
- `users/*.nix`: `myUsers.<name>` data. Importing the file is what creates the user. The schema and the
  system-user/home-manager wiring are in `lib/user-manager.nix` (`users.mutableUsers = false`, so users exist
  only through `myUsers`). Host files refer to a user as `inherit (config.myUsers) dt;` and list them per
  profile with `users = [ dt.name ];`.
- `lib/default.nix`: helpers merged into `lib`: `mkProfileOptions`, `mkProfileHome`.
- `modules/system/`: baseline for every host (`machine.type`, `machine.bootloader.*`, locale, nix
  settings, sops-nix, the user manager) and the per-role sops modules.
- `modules/profiles/`: `profile.<name>` bundles; `default.nix` imports them all and each does nothing until
  enabled. Each has `enable`, `users` (defaults to every user of the host), and its own options.
- `modules/features/*.nix`: system modules behind `features.<name>.enable`, imported by the profile that
  switches them on.
- `modules/features/home/`: plain home-manager modules, imported by profiles.
- `modules/server/`: server services behind `server.<name>.enable` (grafana, loki, prometheus), switched on by
  `profile.monitor`. `postgres.nix` has no switch; the host imports it and sets `server.postgres.user` (the login user with CREATEDB).
- `dotfiles/`, `assets/`: raw config files and wallpapers.

Not wired into any host. Do not use these as examples or fix them in passing: `hosts/zinyak`,
`hosts/desktop-NixOs`, `modules/features/{nh,tws,gnome,kde-plasma}.nix`, and in `modules/features/home/`:
`bash.nix`, `fzf.nix`, `git.nix`, `ghostty.nix`, `plasma.nix`, `gnome-extensions.nix`, `vscode/`.

## Adding things

- Package or program for a user: the fitting profile's `mkProfileHome cfg { ... }` block (see
  `modules/profiles/core.nix`).
- New home-manager module: a file in `modules/features/home/`, imported from a profile's `mkProfileHome`.
- New system feature: `modules/features/x.nix` with `options.features.x.enable` and `mkIf`, imported and
  switched on by a profile (see `modules/features/sway.nix`).
- New knob: extend the profile's `mkProfileOptions`, set the value in the host file.
- Package from unstable: the `pkgsUnstable` module argument, available in both NixOS and home-manager modules.
- No `with lib;`: name what a file uses from `lib` in an `inherit (lib) …;` at the top of its `let`, or write `lib.x`.

## Dotfiles

sway, waybar, kanshi and wezterm use `config.lib.dotfiles.source "<path>"` (in `lib/user-manager.nix`). Its
`live` flag switches all of them in one place: `false` (the default) copies them into the store, so edits need a
rebuild and the repo can live anywhere; `true` symlinks them into `dir` (`~/workspace/nixos-config/dotfiles`),
so edits apply without a rebuild but the repo must stay there and `nixos-rebuild build-vm` cannot follow them.
swaylock, yazi flavors, rofi and the Neovim Lua config are always store copies.

## Sway

Four layers. Pick the right one before editing.

| Layer            | Where                                                                           | Takes effect |
| ---------------- | ------------------------------------------------------------------------------- | ------------ |
| System           | `modules/features/sway.nix`                                                     | rebuild      |
| Home-manager     | `modules/features/home/sway/*.nix`, plus `../wallpapers.nix`, `nemo.nix`, `gtkTheme.nix` | rebuild      |
| Dotfiles         | `dotfiles/sway/config`, `dotfiles/waybar/*`, `dotfiles/kanshi/config`           | rebuild, or sway reload when `live` |
| Workrooms binary | GitHub `detour0/sway-workrooms`, pinned in `modules/features/home/sway/default.nix` | rebuild      |

**System layer.** Enabled by `profile.desktop.environment = "sway"`. Sets up `programs.sway` (with `swayidle`
as the only extra package, which keeps the defaults like foot out), gnome-keyring, and a tty1 autologin that
starts sway from `loginShellInit`. The autologin user `dt` is hardcoded. It attaches the home-manager side with
`home-manager.sharedModules = [ ./home/sway ]`, so that side applies to every
home-manager user on the host, not only the profile's `users`.

**Home-manager layer.** Owns packages (grim, slurp, dunst, autotiling, cliphist, zathura and so on), mime
defaults, GTK and cursor theme. It enables `wayland.windowManager.sway` only for the wrapper; the config it
would generate is replaced with `mkForce` by the dotfile. So keybindings, window rules and autostart go
in `dotfiles/sway/config`, never in home-manager sway options.

**Passing store paths into the dotfile.** Home-manager writes `~/.config/sway/script-vars.conf`, which sets
`$workrooms_bin`, `$wallpaper` and `$urgent_focus_bin`, and the dotfile's first line includes it. Anything else the sway config
needs from the Nix store goes through that file. The wallpaper is the custom home-manager option
`config.wallpaper`, defined in `wallpapers.nix`.

**What starts what.** Sway `exec`s waybar, swayidle, autotiling and the urgent-focus script. Waybar's systemd
unit is off on purpose, since having both loads it twice. dunst (D-Bus activated), cliphist and kanshi are
systemd user services from home-manager, so they get no `exec`; the sway config only restarts kanshi with
`exec_always`. `kanshi-profile <name>` appends the current output layout to `dotfiles/kanshi/config` under `dir`
(rebuild afterwards unless `live`). All
lock-screen styling lives in the store-copied `dotfiles/swaylock/everforest.conf`; swayidle and wlogout call
plain `swaylock` without colour flags. Colours used from Nix (dunst, wlogout) come from
`modules/features/home/sway/everforest.nix`.

**Workrooms.** A workroom is a set of workspaces, one per output. The workspace number is
`workroom * 10 + output position`, counting outputs left to right from 1, so workroom 2 is workspaces 21, 22, 23.

- `$mod+z/x/c/v/b` switch to workroom 1 to 5. `$mod+n` and `$mod+m` are global workspaces outside the scheme.
- `$mod+1..9` go to `$$workroom<N>`. The double `$` defers expansion, so the `set $$workroom N` in each switch
  binding retargets the number keys.
- Subcommands: `setup`, `switch`, `move_container`, `move_workspace`, `swap`. Errors go to `/tmp/workroom.log`.
- The build fetches the GitHub source at the pinned `rev`; there is no copy of the tool in this repo. A change
  to it needs a push to the upstream repo, then a new `rev` and `hash` (set `lib.fakeHash`, build, copy the
  reported hash). Say this to the user.

**Checking.** `sway --validate -c ~/.config/sway/config` is safe to run. `swaymsg reload` and
`pkill -SIGUSR2 waybar` act on the user's running session, so ask first.

## Neovim

`modules/features/home/nvim/`, pulled in by `profile.dev.editor = "nvim"`. Written for Neovim 0.12.

- Nix installs everything; lazy.nvim only loads. The real init is `initLua` in `default.nix`: it puts lazy.nvim
  on the runtimepath from the Nix pack, points `dev.path` at that pack and switches off installing, updating and
  change detection. The pack is deliberately not on Neovim's packpath, so a plugin without a spec does not exist.
- `config/lua` is copied to `~/.config/nvim/lua` from the store. Lua edits need a rebuild, and new Lua files
  need `git add`.
- **Adding a plugin takes two edits.**
  1. `pkgs.vimPlugins.<attr>` in `plugins`. Use `pkgsUnstable.vimPlugins` only when stable is too old.
  2. A spec in `config/lua/plugins/<name>.lua` with `dev = true`. The spec name must be the plugin's directory
     name in the pack, which often differs from the Nix attribute: `blink-cmp` is `"blink.cmp"`,
     `conform-nvim` is `"conform.nvim"`, `telescope-nvim` is `"telescope.nvim"`.

  A missing or misnamed plugin fails silently. No `build =` steps, no Mason, nothing that downloads at runtime.
- **Everything is lazy by default** (`defaults.lazy = true`). A spec loads on its `event`, `cmd`, `keys` or
  `ft`, when something `require()`s it, or with `lazy = false`. Libraries that only get required or named in
  `dependencies` are listed once in `plugins/libs.lua`.
- **Adding a language takes up to four edits**: the binary in `extraPackages`; the server name in the `servers`
  list in `plugins/lsp.lua`; the formatter in `plugins/conform.lua`; the linter in `plugins/lint.lua`. LSP setup
  uses `vim.lsp.config` and `vim.lsp.enable` (nvim-lspconfig only supplies the server definitions), and
  buffer keymaps are set in an `LspAttach` autocmd, not through `on_attach`.
- **Treesitter.** Parsers and queries for every language come from `nvim-treesitter.withAllGrammars`, merged into
  one pack directory that `initLua` adds to the runtimepath. Highlighting is Neovim's own, started per buffer by
  the `FileType` autocmd in `plugins/treesitter.lua`. The nvim-treesitter plugin is the rewrite (`main`): there
  is no `nvim-treesitter.configs`, no `ensure_installed`, and textobject keymaps are defined by hand in that file.
- Layout: `config/lua/config/{opts,keys,autocmds}.lua` for core settings (leader is space), one file per
  plugin or topic under `config/lua/plugins/`. Completion is blink.cmp (snippets through `vim.snippet`), the
  picker is telescope, the theme is everforest.
- Lua style: tabs, `local v = vim`, stylua formatting, a `desc` on every keymap (which-key shows it).
- `dotfiles/nvim/` is an old VS Code Neovim config, not this one.
- A successful build does not put anything live. Do not report a keymap or plugin as tested until the user
  has switched and tried it.

## Verifying

None of these need root.

- `nix flake check --no-build`: evaluates every host. Needs SSH access to the private `nix-secrets` repo.
- `nixos-rebuild build --flake .#shaundi`: full build, writes the gitignored `./result`.
- `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run`: for the servers.
- Add `--show-trace` on evaluation errors.
- Nix files are formatted with `nixfmt` and linted with `statix`. Neither is on PATH outside Neovim:
  `nix run nixpkgs#nixfmt -- <file>`, `nix run nixpkgs#statix -- check <file>`.

## Applying (user only)

- `sudo nixos-rebuild switch --flake .#shaundi`
- `deploy .#schiggi`, `deploy .#digda`
- `nix flake update nix-secrets` after a change in the secrets repo
