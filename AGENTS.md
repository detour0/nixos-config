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
- Never change `system.stateVersion` or `stateVersionH`; they are pinned per host.
- Never inline secrets, IPs or keys, and never print decrypted values. They come from
  `inputs.nix-secrets.<...>` (plain values) or sops (`config.sops.secrets.<name>.path`).
- `nix flake update [input]` only when asked.
- Commit only when asked. Style: `feat: …` / `fix: …`, lowercase, comma-separated summary.
- `git add` new files before building: a flake only sees git-tracked files, so an untracked file "does not exist".

## Layout

- `flake.nix`: inputs, `nixosConfigurations`, `deploy.nodes`.
- `hosts/<name>/default.nix`: imports and option values only. No logic here; put it in a profile or feature.
- `users/*.nix`: `myUsers.<name>` data. The schema and the system-user/home-manager wiring are in
  `lib/user-manager.nix` (`users.mutableUsers = false`, so users exist only through `myUsers`).
- `lib/default.nix`: helpers merged into `lib`: `mkProfileOptions`, `mkProfileHome`, `mkFeatureBridge`.
- `modules/system/`: baseline for every host (`machine.type`, `machine.bootloader.*`, locale, nix settings)
  and the per-role sops modules.
- `modules/profiles/`: `profile.<name>` bundles. Each has `enable`, `users`, and its own options.
- `modules/features/*.nix`: system modules behind `features.<name>.enable`.
- `modules/features/home/`: plain home-manager modules, imported by profiles.
- `modules/server/`: server services (postgres, grafana, loki, prometheus).
- `dotfiles/`, `assets/`: raw config files and wallpapers.

Not wired into any host. Do not use these as examples or fix them in passing: `hosts/zinyak`,
`hosts/desktop-NixOs`, `overlays/`, `modules/server/redis.nix`, `modules/features/{nh,tws,gnome,kde-plasma}.nix`,
and in `modules/features/home/`: `default.nix`, `common.nix`, `bash.nix`, `fzf.nix`, `git.nix`, `ghostty.nix`,
`plasma.nix`, `gnome-extensions.nix`, `vscode/`.

## Adding things

- Package or program for a user: the fitting profile's `mkProfileHome` block (see `modules/profiles/core.nix`).
- New home-manager module: a file in `modules/features/home/`, imported from a profile's `mkProfileHome`.
- New system feature: `modules/features/x.nix` with `options.features.x.enable` and `mkIf`, imported and
  switched on by a profile (see `modules/features/sway.nix`).
- New knob: extend the profile's `mkProfileOptions`, set the value in the host file.
- Package from unstable: the `pkgsUnstable` module argument, available in both NixOS and home-manager modules.
- Match the idiom of the file you are in (`with lib;` in profiles, `inherit (lib) …` in `lib/` and `modules/system/`).

## Dotfiles: live or copied

Live symlinks (`mkOutOfStoreSymlink` to `~/workspace/nixos-config/dotfiles/...`): sway, waybar, kanshi, wezterm.
Edits take effect without a rebuild, and the repo must stay at that path.

Store copies, which need a rebuild: swaylock, yazi flavors, the Neovim Lua config.

## Sway

Four layers. Pick the right one before editing.

| Layer            | Where                                                                           | Takes effect |
| ---------------- | ------------------------------------------------------------------------------- | ------------ |
| System           | `modules/features/sway.nix`                                                     | rebuild      |
| Home-manager     | `modules/features/home/sway/*.nix`, plus `../wallpapers.nix`, `nemo.nix`, `gtkTheme.nix` | rebuild      |
| Dotfiles         | `dotfiles/sway/config`, `dotfiles/waybar/*`, `dotfiles/kanshi/config`           | sway reload  |
| Workrooms binary | GitHub `detour0/sway-workrooms`, pinned in `modules/features/home/sway/default.nix` | rebuild      |

**System layer.** Enabled by `profile.desktop.environment = "sway"`. Sets up `programs.sway` (with `swayidle`
as the only extra package, which keeps the defaults like foot out), gnome-keyring, and a tty1 autologin that
starts sway from `loginShellInit`. The autologin user `dt` is hardcoded. It attaches the home-manager side with
`home-manager.sharedModules = [ (lib.mkFeatureBridge ./home/sway) ]`, so that side applies to every
home-manager user on the host, not only the profile's `users`.

**Home-manager layer.** Owns packages (grim, slurp, mako, autotiling, cliphist, zathura and so on), mime
defaults, GTK and cursor theme. It enables `wayland.windowManager.sway` only for the wrapper; the config it
would generate is replaced with `mkForce` by the dotfile symlink. So keybindings, window rules and autostart go
in `dotfiles/sway/config`, never in home-manager sway options.

**Passing store paths into the dotfile.** Home-manager writes `~/.config/sway/script-vars.conf`, which sets
`$workrooms_bin` and `$wallpaper`, and the dotfile's first line includes it. Anything else the sway config
needs from the Nix store goes through that file. The wallpaper is the custom home-manager option
`config.wallpaper`, defined in `wallpapers.nix`.

**What starts what.** Sway `exec`s waybar and mako. Waybar's systemd unit is off on purpose, since having both
loads it twice. Kanshi is a systemd user service that the sway config restarts with `exec_always`.
`kanshi-profile <name>` appends the current output layout to `dotfiles/kanshi/config`. All lock-screen styling
lives in the store-copied `dotfiles/swaylock/everforest.conf`; `$lock`, `swayidle` and wlogout call plain
`swaylock` without colour flags.

**Workrooms.** A workroom is a set of workspaces, one per output. The workspace number is
`workroom * 10 + output position`, counting outputs left to right from 1, so workroom 2 is workspaces 21, 22, 23.

- `$mod+z/x/c/v/b` switch to workroom 1 to 5. `$mod+n` and `$mod+m` are global workspaces outside the scheme.
- `$mod+1..9` go to `$$workroom<N>`. The double `$` defers expansion, so the `set $$workroom N` in each switch
  binding retargets the number keys.
- Subcommands: `setup`, `switch`, `move_container`, `move_workspace`, `swap`. Errors go to `/tmp/workroom.log`.
- The build fetches the GitHub source at the pinned `rev`. `modules/features/home/sway/scripts/workrooms/` is an
  in-repo copy that nothing builds (same `main.rs` as upstream at the time of writing). A change to the tool
  needs a push to the upstream repo, then a new `rev` and `sha256` (set `lib.fakeHash`, build, copy the reported
  hash). Say this to the user; do not edit the local copy and call it done.

**Checking.** `sway --validate -c ~/.config/sway/config` is safe to run. `swaymsg reload` and
`pkill -SIGUSR2 waybar` act on the user's running session, so ask first.

**VM testing.** `nixos-rebuild build-vm` cannot follow the out-of-store symlinks. The commented-out store-copy
lines in `home/sway/default.nix` and `waybar.nix` are the switch for that.

## Neovim

`modules/features/home/nvim/`, pulled in by `profile.dev.editor = "nvim"`.

- Nix installs everything; lazy.nvim only loads. The real init is `initLua` in `default.nix`, which points
  lazy's `dev.path` at the Nix pack directory and sets `install.missing = false`. `config/init.lua` is empty
  and unused.
- `config/lua` is copied to `~/.config/nvim/lua` from the store. Lua edits need a rebuild, and new Lua files
  need `git add`.
- **Adding a plugin takes two edits.**
  1. `pkgs.vimPlugins.<attr>` in `plugins`. Use `pkgsUnstable.vimPlugins` only when stable is too old, as with
     blink-cmp.
  2. A spec in `config/lua/plugins/<name>.lua` with `dev = true`. The spec name must be the plugin's directory
     name in the pack, which often differs from the Nix attribute: `blink-cmp` is `"blink.cmp"`,
     `conform-nvim` is `"conform.nvim"`, `telescope-nvim` is `"telescope.nvim"`.

  A missing or misnamed plugin fails silently. No `build =` steps, no Mason, nothing that downloads at runtime.
- **Adding a language takes up to five edits**: the binary in `extraPackages`; the server name in the `lsps`
  list in `plugins/lsp/init.lua`; the formatter in `plugins/conform.lua`; the linter in `plugins/lint.lua`; the
  grammar in the treesitter list. LSP setup uses the Neovim 0.11+ API (`vim.lsp.config`, `vim.lsp.enable`),
  not `lspconfig.<server>.setup`.
- Layout: `config/lua/config/{opts,keys,autocmds}.lua` for core settings (leader is space), one file per
  plugin under `config/lua/plugins/`, shared LSP keymaps in `plugins/lsp/on_attach.lua`. Completion is
  blink.cmp, the picker is telescope, the theme is everforest.
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
