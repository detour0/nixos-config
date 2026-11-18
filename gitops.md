# Git in Neovim

Diffs and staging go through diffview.nvim (`<leader>` is Space). There is no commit command in Neovim yet, so
committing goes through git.

## Open a view

| Key                   | Shows                                                        |
| --------------------- | ------------------------------------------------------------ |
| `<leader>gd`          | All uncommitted changes, staged and unstaged (again: close)  |
| `<leader>gs`          | Only the staged changes, i.e. what the next commit contains  |
| `<leader>gl`          | The changes including the last commit                        |
| `<leader>gh`          | History of the current file                                  |
| `<leader>gh` (visual) | History of the selected lines                                |
| `<leader>gH`          | History of the whole repo                                    |
| `<leader>gf`          | Show or hide the file panel                                  |
| `<leader>gq`          | Close the view                                               |

## Inside a view

| Key                 | Does                                              |
| ------------------- | ------------------------------------------------- |
| `<Tab>` / `<S-Tab>` | Next / previous file                              |
| `-`                 | Stage or unstage the file under the cursor        |
| `S` / `U`           | Stage all / unstage all                           |
| `X`                 | Discard the changes to the file under the cursor  |
| `]c` / `[c`         | Next / previous change in the diff                |
| `do` / `dp`         | Take the change from / put it into the other side |
| `g?`                | All mappings                                      |

## Commit

- One line: `:!git commit -m "feat: …"`
- Longer message: `:terminal git commit`, write it, `:wq`, close the terminal.
- Or from the shell.

## Workflow for this repo

1. Edit, then `git add` new files before building: a flake only sees tracked files.
2. Build to check: `nixos-rebuild build --flake .#shaundi`.
3. `<leader>gd` to review, stage with `-` or `S`, `<leader>gs` to check what goes in.
4. Commit in the style `feat: …` / `fix: …`, lowercase, comma-separated summary.
5. Apply: `sudo nixos-rebuild switch --flake .#shaundi`, `deploy .#schiggi`, `deploy .#digda`.
