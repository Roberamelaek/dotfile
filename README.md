# dotfiles

Personal, professional dotfiles for Neovim, Tmux, Git, and bash on Arch Linux.

[![Neovim](https://img.shields.io/badge/Neovim-0.10%2B-57A143?logo=neovim&logoColor=white)](https://neovim.io)
[![Tmux](https://img.shields.io/badge/Tmux-3.3%2B-1BB91F?logo=gnu&logoColor=white)](https://github.com/tmux/tmux)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Features

### Neovim
- rose-pine theme (transparent), lualine statusline, bufferline tabs
- Unified `Ctrl+h/j/k/l` pane navigation shared with tmux
- LSP completion (nvim-cmp), Telescope, Treesitter, which-key, snacks dashboard,
  nvim-tree, mini.pairs, Obsidian support

### Tmux
- Prefix `Ctrl-a`, rose-pine moon theme matching Neovim
- Session persistence: `Ctrl-a s` save, `Ctrl-a r` restore (tmux-resurrect)
- tmux-yank, fzf, tmux-sessionx (TPM)

### Shell
- Colored prompt with git branch, date/time, and exit-code indicator
- Handy aliases and bash completion

## Install

```bash
git clone https://github.com/Roberamelaek/dotfile ~/.dotfiles
cd ~/.dotfiles && bash install.sh
```

Preview without changing anything:

```bash
bash install.sh --dry-run
```

## Layout

```
.dotfiles/
├── nvim/              # Neovim config (symlinked to ~/.config/nvim)
├── tmux/tmux.conf     # → ~/.tmux.conf
├── shell/             # .prompt, .alias
├── obsidian/          # mycss.css
├── assets/            # wall.png
├── scripts/           # install.sh, bootstrap.sh, link.sh, git-setup.sh, lib/
├── nbrc               # `nb` notes config
└── README.md
```

## Uninstall

```bash
rm -f ~/.config/nvim ~/.tmux.conf ~/.nbrc ~/.prompt ~/.alias
rm -rf ~/.tmux/plugins
# remove the two `source ~/.prompt` / `source ~/.alias` lines from ~/.bashrc
```

## FAQ

- **Why Arch-only?** The installer targets Arch Linux (`pacman`). The configs
  themselves are distro-agnostic.
- **How do I add a plugin?** Add one file to `nvim/lua/plugins/`.

## License

MIT
