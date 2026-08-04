# Dotfiles Professional Overhaul — Design

Date: 2026-08-04
Status: Approved (approach 2: Professional overhaul)

## Goal

Transform the personal dotfiles repo into a professional, cohesive, well-organized
project: readable structured code, integrated tmux + nvim experience, polished
visuals (rose-pine everywhere), gorgeous install output, and a professional README.

## Requirements

1. Updated professional README (badges, features, layout, install/uninstall, usage).
2. More readable, structured, clean, efficient code with proper file naming.
3. Looks good while using it: rose-pine theme throughout nvim AND tmux, nvim
   statusline + file tabs, unified pane navigation between nvim and tmux,
   session integration.
4. Good-looking shell comments/output when installing the dotfiles.

## Repo Layout

```
.dotfiles/
├── nvim/                        # Neovim config → symlinked to ~/.config/nvim
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── config/
│       │   ├── lazy.lua         # lazy.nvim bootstrap + install settings
│       │   └── options.lua      # all vim.opt settings (from old set.lua)
│       └── plugins/             # one file per plugin (all rose-pine themed)
│           ├── colorscheme.lua  # rose-pine (transparent)
│           ├── lualine.lua      # NEW: statusline
│           ├── bufferline.lua   # NEW: file tabs
│           ├── tmux-navigator.lua # NEW: shared vim/tmux navigation
│           ├── treesitter.lua
│           ├── cmp.lua
│           ├── telescope.lua
│           ├── which-key.lua
│           ├── snack.lua
│           ├── nvim-tree.lua    # renamed out of formatter.lua
│           ├── mini-pairs.lua   # split out of formatter.lua
│           └── obsidian.lua
├── tmux/
│   └── tmux.conf                # → symlinked to ~/.tmux.conf
├── shell/
│   ├── .alias
│   └── .prompt                  # finished & enabled
├── obsidian/
│   └── mycss.css                # Obsidian theme (moved out of scripts/)
├── assets/
│   └── wall.png                 # wallpaper (moved)
├── scripts/
│   ├── lib/
│   │   └── ui.sh                # pretty output helpers (colors, sections, checkmarks)
│   ├── install.sh               # single entry point → runs all steps
│   ├── bootstrap.sh             # installs packages (vim/tmux/git/nvim)
│   ├── link.sh                  # creates all symlinks (idempotent)
│   └── git-setup.sh             # git aliases
├── .github/                     # issue templates (kept)
├── nbrc                         # standalone `nb` notes config (stays at root)
└── README.md
```

## Neovim Changes

### New plugins
- **lualine.nvim** — modern statusline using rose-pine built-in theme: mode, branch,
  filetype, diagnostics, progress, transparent background.
- **bufferline.nvim** — file tabs along the top, rose-pine colored, icon + filename
  + modified dot.
- **vim-tmux-navigator** — same `Ctrl+h/j/k/l` to move between nvim windows and
  tmux panes seamlessly.

### Existing plugins cleaned
- `formatter.lua` → split into `nvim-tree.lua` + `mini-pairs.lua` (proper names).
- `treesitter.lua` — drop `:wait(600000)` sync install (hangs startup); use async
  install, no timeout.
- `snack.lua` — dashboard header and keys stay.
- `theme.lua` → renamed `colorscheme.lua`, rose-pine setup + transparent bg.

### Config structure
- `lua/config/options.lua` — all editor settings (numbers, tabs, search, scrolloff,
  signcolumn) grouped with comments. Content is recovered from the deleted-but-
  still-in-git-history `lua/set.lua` (`git show HEAD:.config/nvim/lua/set.lua`).
- `lua/config/lazy.lua` — bootstrap only.

## Tmux Changes

- Keep TPM plugins: tmux-resurrect (session persistence), tmux-sessionx,
  tmux-yank, fzf, rose-pine/tmux (moon variant — matches nvim rose-pine).
- Status bar: enable rose-pine theme + clean statusbar config (session/window/pane
  info, same accent colors as nvim).
- vim-tmux-navigator bindings added to tmux.conf (`Ctrl+hjkl`). This requires the
  standard `is_vim` detection snippet (`if-shell` + `is_vim` env check) so tmux
  hands the key to nvim when a nvim instance is in the pane — otherwise the
  unified Ctrl+hjkl navigation does not work.
- Session integration: tmux-resurrect saves/restores with `Ctrl-a s` / `Ctrl-a r`;
  keep `@resurrect-strategy-nvim 'session'` to restore nvim sessions.
- install.sh installs TPM (currently referenced but never installed).

## Shell Changes

- `.prompt`: finish and enable `set_PS1` — git branch, colored segments, date/time,
  exit-code indicator; bash-compatible.
- `.alias`: keep + add a few sensible ones (e.g. lazy).
- `scripts/lib/ui.sh`: shared helpers — `info`, `success`, `warn`, `error`,
  section banners, checkmarks, spinner for long installs.
- `bootstrap.sh`: Arch-only, uses `pacman` consistently for package checks +
  installs (current `install.sh` mixes a `dpkg -l` probe with `pacman` — that
  inconsistency is removed).
- `install.sh` = pretty driver: bootstrap → link → git-setup, each printing colored
  sectioned output; `--dry-run` preview; idempotent (no .bashrc duplicates).

## README

- Badges (neovim version, tmux, license), screenshot section (placeholder).
- Repo layout (the tree above).
- Quick start: one command `bash install.sh`.
- What's included: nvim features + keymaps, tmux features, shell bits.
- Uninstall + FAQ, license.

## Files Removed

- `vimrc` — nvim fully replaces vim; `~/.vimrc` symlink dropped.
- `gitconfig/gitinstall.sh` — folded into `scripts/git-setup.sh`.
- `scripts/install_init_vim.sh` — logic folded into `scripts/link.sh`.
- Old `lua/*.lua` vim-plug files (deleted in working tree but **uncommitted**).
  The lazy.nvim migration is currently unstaged on branch `Lazy`; the
  implementation plan starts with a commit of that migration as its baseline.

## Files Moved

- `.config/nvim/` → `nvim/` (top level).
- `.config/wall.png` → `assets/wall.png`.
- `scripts/mycss.css` → `obsidian/mycss.css`.
- `.prompt`/`.alias` → `shell/`.
- `tmuxrc` → `tmux/tmux.conf`.

## Files Kept

- `.github/` issue templates.
- `nbrc` (standalone `nb` notes config, stays at root).
- `lazy-lock.json` (regenerated after plugin changes).

## Non-Goals

- No zsh/fish support (bash only).
- No install CLI flags beyond `--dry-run` and `--help`.
- No migration of `nb`/`nbrc` behavior.
