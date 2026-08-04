# Dotfiles Professional Overhaul — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the personal dotfiles repo into a professional, cohesive project: restructured layout, integrated tmux + nvim experience (rose-pine themed, unified Ctrl+hjkl navigation, lualine statusline + bufferline tabs), polished install output, and a professional README.

**Architecture:** A single bash-driven installer organized as `scripts/{install,bootstrap,link,git-setup}.sh` sharing a `scripts/lib/ui.sh` pretty-output library. Neovim config moves to a top-level `nvim/` with lazy.nvim loading one file per plugin from `lua/plugins/`. Tmux config lives in `tmux/tmux.conf` and is symlinked to `~/.tmux.conf`. Everything is git-managed; symlinks and `.bashrc` edits are idempotent.

**Tech Stack:** bash (only, Arch/pacman), lazy.nvim + lua, TPM + tmux plugins (rose-pine/tmux, tmux-resurrect), nvim plugins (rose-pine, lualine, bufferline, vim-tmux-navigator, treesitter, cmp, telescope, which-key, snacks, nvim-tree, mini.pairs, obsidian).

**Baseline note:** All commands in this plan run from the repo root `/home/roba/.dotfiles` unless stated. Verification tools on host: `nvim`, `tmux`, `git`, `bash` (no `shellcheck` — use `bash -n`). The current lazy.nvim migration is uncommitted on branch `Lazy`; Task 1 fixes that.

---

### Task 1: Commit the lazy.nvim migration baseline

**Files:**
- No new files. Commits the entire current uncommitted working tree (deleted vim-plug era files, new `lua/config/`, `lua/plugins/`, modified `init.lua`, `.prompt`, `README.md`, `scripts/install.sh`).

- [ ] **Step 1: Inspect what will be committed**

Run: `git status --short`
Expected: the deleted vim-plug files (`plug.vim`, `init.vim`, `cmpss.lua`, `set.lua`, `treesitter.lua`, `plugins.lua`, `plugin.lua`, `colorscheme.lua`, `copilot.vim`), modified files (`init.lua`, `lazy-lock.json`, `.prompt`, `README.md`, `scripts/install.sh`), and untracked `lua/config/` + `lua/plugins/` dirs.

- [ ] **Step 2: Add the check script (test harness for this plan)**

Create `scripts/ci/check-config.sh`:

```bash
#!/usr/bin/env bash
# Sandboxed checks for every lua file under nvim/ and for tmux.conf.
# Compiles each lua file with loadfile (no execution, no plugin downloads).
# Usage: bash scripts/ci/check-config.sh  (run from repo root)
set -u
cd "$(dirname "$0")/../.." || exit 1
fail=0

nlua() {
  nvim --headless -c "lua assert(loadfile('$1'))" -c 'qa' 2>&1 \
    | grep -Ei 'error|E[0-9]{3,}' \
    && { echo "FAIL: $1"; fail=1; } || true
}

for f in nvim/init.lua nvim/lua/config/*.lua nvim/lua/plugins/*.lua; do
  nlua "$f"
done

tmuxcheck() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "SKIP: tmux not installed"
    return 0
  fi
  local sock="dotfiles-plan-$$"
  tmux -L "$sock" -f "$1" new-session -d -s test 2>&1 \
    | grep -i error && { echo "FAIL: $1"; fail=1; } || true
  tmux -L "$sock" kill-server 2>/dev/null || true
}

tmuxcheck tmux/tmux.conf

exit $fail
```

Notes: `loadfile` compiles without running, so plugin specs with `config = function() ... end` are validated without executing `require` calls. `tmuxcheck` uses a unique socket (`-L`), so it never touches your running tmux server. The tmux check is a no-op until Task 2 creates `tmux/tmux.conf`, and the script is only *run* from Task 3 onward — committing it here just fixes the harness in place.

- [ ] **Step 3: Stage everything and commit the baseline**

Run:
```bash
git add -A
git commit -m "refactor(nvim): migrate from vim-plug to lazy.nvim layout"
```

- [ ] **Step 4: Verify clean tree**

Run: `git status --short`
Expected: no output (empty working tree).

---

### Task 2: Restructure the repository into the new layout

**Files:**
- Move: `.config/nvim/` → `nvim/`
- Move: `.config/wall.png` → `assets/wall.png`
- Move: `scripts/mycss.css` → `obsidian/mycss.css`
- Move: `.prompt` → `shell/.prompt`, `.alias` → `shell/.alias`
- Move: `tmuxrc` → `tmux/tmux.conf`
- Delete: `vimrc`, `gitconfig/gitinstall.sh`, `scripts/install_init_vim.sh`

- [ ] **Step 1: Write the failing test**

Run: `ls nvim shell assets obsidian tmux 2>&1`
Expected: `ls: cannot access 'nvim': No such file or directory` (repeated for each) — proving the moves are still to be done.

- [ ] **Step 2: Perform the moves and deletions**

Run:
```bash
mkdir -p assets obsidian shell tmux
git mv .config/nvim nvim
git mv .config/wall.png assets/wall.png
git mv scripts/mycss.css obsidian/mycss.css
git mv .prompt shell/.prompt
git mv .alias shell/.alias
git mv tmuxrc tmux/tmux.conf
git rm vimrc gitconfig/gitinstall.sh scripts/install_init_vim.sh
rmdir .config gitconfig 2>/dev/null || true
```

- [ ] **Step 3: Verify the test now passes**

Run: `ls nvim shell assets obsidian tmux 2>&1` and `git status --short`
Expected: the five dirs list without errors; `git status` shows `R` entries for the moves and `D` entries for the deletions.

- [ ] **Step 4: Commit**

Run:
```bash
git add -A
git commit -m "refactor: reorganize repo into nvim/tmux/shell/obsidian/assets layout"
```
---

### Task 3: Recreate editor options (options.lua)

**Files:**
- Create: `nvim/lua/config/options.lua`
- Modify: `nvim/init.lua`

Recover the settings from the deleted-but-in-history `lua/set.lua` (`git show HEAD:.config/nvim/lua/set.lua`). Do NOT copy `vim.g.mapleader` — it lives in `config/lazy.lua`.

- [ ] **Step 1: Write the failing test**

Probe for the missing file:
```bash
test -f nvim/lua/config/options.lua || echo "FAILS AS EXPECTED"
```
Expected: prints `FAILS AS EXPECTED` (options.lua does not exist yet).

- [ ] **Step 2: Create `nvim/lua/config/options.lua`**

```lua
-- Global editor options.
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.termguicolors = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- Conceal links/emphasis in markdown (obsidian friendly).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
  end,
})
```

- [ ] **Step 3: Wire it into `nvim/init.lua`**

Replace the content of `nvim/init.lua` with:

```lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.lazy")
```

- [ ] **Step 4: Run the test to verify it passes**

Run:
```bash
bash scripts/ci/check-config.sh
test -f nvim/lua/config/options.lua && echo "options.lua exists"
nvim --headless -c "set rtp+=$PWD/nvim" -c 'luafile nvim/lua/config/options.lua' -c 'echo &number' -c 'qa'
```
Expected: no `FAIL:` lines from the harness; `options.lua exists`; `1` printed (the option took effect).

- [ ] **Step 5: Commit**

Run:
```bash
git add nvim
git commit -m "feat(nvim): add options.lua recovered from legacy set.lua"
```

---

### Task 4: Reorganize existing plugin files

**Files:**
- Rename: `nvim/lua/plugins/theme.lua` → `nvim/lua/plugins/colorscheme.lua`
- Rename: `nvim/lua/plugins/nvim-treesitter.lua` → `nvim/lua/plugins/treesitter.lua`
- Delete: `nvim/lua/plugins/formatter.lua`
- Create: `nvim/lua/plugins/nvim-tree.lua`, `nvim/lua/plugins/mini-pairs.lua`
- Modify: `nvim/lua/plugins/treesitter.lua` (drop `:wait(600000)`), `nvim/lua/config/lazy.lua` (bootstrap only)

- [ ] **Step 1: Rename colorscheme and treesitter files**

Run:
```bash
git mv nvim/lua/plugins/theme.lua nvim/lua/plugins/colorscheme.lua
git mv nvim/lua/plugins/nvim-treesitter.lua nvim/lua/plugins/treesitter.lua
```

- [ ] **Step 2: Drop the synchronous treesitter wait**

Replace the contents of `nvim/lua/plugins/treesitter.lua` with:

```lua
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- Install parsers asynchronously on first startup; no blocking :wait().
    require('nvim-treesitter').install {
      'bash', 'c', 'cmake', 'comment', 'cpp', 'css', 'diff', 'dockerfile', 'go',
      'html', 'java', 'javascript', 'json', 'json5', 'lua', 'make', 'markdown',
      'markdown_inline', 'python', 'query', 'regex', 'sql', 'toml', 'tsx',
      'typescript', 'vim', 'vimdoc', 'xml', 'yaml',
    }
  end,
}
```

- [ ] **Step 3: Split `formatter.lua` into properly-named files**

Create `nvim/lua/plugins/nvim-tree.lua`:

```lua
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = { { "nvim-tree/nvim-web-devicons", version = "*" } },
  lazy = false,
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
    { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal file in tree" },
  },
  config = function()
    require("nvim-tree").setup {
      filters = { dotfiles = true },
      renderer = { group_empty = true, indent_width = 1 },
    }
  end,
}
```

Create `nvim/lua/plugins/mini-pairs.lua`:

```lua
return {
  "nvim-mini/mini.pairs",
  version = "*",
  event = "InsertEnter",
}
```

Delete `nvim/lua/plugins/formatter.lua`:

Run: `git rm nvim/lua/plugins/formatter.lua`

- [ ] **Step 4: Make `config/lazy.lua` bootstrap-only**

Replace the contents of `nvim/lua/config/lazy.lua` with:

```lua
-- Bootstrap lazy.nvim (this file is the only loader entry point).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
```

- [ ] **Step 5: Run the test to verify everything still loads**

Run: `bash scripts/ci/check-config.sh`
Expected: no `FAIL:` lines.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor(nvim): rename theme/treesitter, split formatter.lua, slim lazy.lua"
```

---

### Task 5: Add lualine statusline

**Files:**
- Create: `nvim/lua/plugins/lualine.lua`

- [ ] **Step 1: Write the failing test**

Run: `bash scripts/ci/check-config.sh`
Expected: `FAIL: nvim/lua/plugins/lualine.lua` (module missing).

- [ ] **Step 2: Create `nvim/lua/plugins/lualine.lua`**

```lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local theme = require("lualine.themes.rose-pine")
    for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }) do
      if theme[mode] and theme[mode].c then
        theme[mode].c.bg = "none" -- transparent to match the transparent nvim theme
      end
    end

    require("lualine").setup({
      options = {
        theme = theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bash scripts/ci/check-config.sh`
Expected: no `FAIL:` lines.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/lualine.lua
git commit -m "feat(nvim): add rose-pine lualine statusline"
```

---

### Task 6: Add bufferline file tabs

**Files:**
- Create: `nvim/lua/plugins/bufferline.lua`

- [ ] **Step 1: Write the failing test**

Run: `bash scripts/ci/check-config.sh`
Expected: `FAIL: nvim/lua/plugins/bufferline.lua` (module missing).

- [ ] **Step 2: Create `nvim/lua/plugins/bufferline.lua`**

```lua
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("bufferline").setup {
      options = {
        mode = "tabs", -- show a tab for each buffer
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        show_buffer_icons = true,
        separator_style = "slant",
        offsets = {
          { filetype = "NvimTree", text = "File Explorer", text_align = "left", separator = true },
        },
      },
    }
  end,
}
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bash scripts/ci/check-config.sh`
Expected: no `FAIL:` lines.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/bufferline.lua
git commit -m "feat(nvim): add bufferline tabs"
```

---

### Task 7: Add vim-tmux-navigator

**Files:**
- Create: `nvim/lua/plugins/tmux-navigator.lua`

- [ ] **Step 1: Write the failing test**

Run: `bash scripts/ci/check-config.sh`
Expected: `FAIL: nvim/lua/plugins/tmux-navigator.lua` (module missing).

- [ ] **Step 2: Create `nvim/lua/plugins/tmux-navigator.lua`**

```lua
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>NvimTmuxNavigateLeft<CR>" },
    { "<C-j>", "<cmd>NvimTmuxNavigateDown<CR>" },
    { "<C-k>", "<cmd>NvimTmuxNavigateUp<CR>" },
    { "<C-l>", "<cmd>NvimTmuxNavigateRight<CR>" },
  },
}
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bash scripts/ci/check-config.sh`
Expected: no `FAIL:` lines.

- [ ] **Step 4: Commit**

```bash
git add nvim/lua/plugins/tmux-navigator.lua
git commit -m "feat(nvim): add vim-tmux-navigator for unified pane movement"
```

---

### Task 8: Rewrite tmux.conf (rose-pine, navigation, session integration)

**Files:**
- Modify: `tmux/tmux.conf`

- [ ] **Step 1: Write the failing test**

Run: `grep -c 'is_vim' tmux/tmux.conf`
Expected: `0` (the `is_vim` detection and resurrect bindings are added in this task).

- [ ] **Step 2: Replace `tmux/tmux.conf`**

```tmux
# ─────────────────────────────────────────────────────────────
#  tmux.conf — dotfiles
#  prefix: Ctrl-a  |  pane nav: Ctrl+hjkl (shared with nvim)
# ─────────────────────────────────────────────────────────────

set -g prefix C-a
unbind C-b
bind a send-prefix

# Split windows while keeping the current path
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
set -g renumber-windows on
set -g base-index 0
set -g pane-base-index 0

# vim-like copy mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

unbind '"'
unbind %

# prefix + hjkl pane navigation
bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R

# ── vim-tmux-navigator: hand Ctrl+hjkl to nvim when one is in the pane ──
is_vim="ps -o state= -o comm= -t '#{pane_pid}' \
    | grep -iqE '^[^TXZ ]+ +\\S*\\d+(\\S*|/)(vi|vim|n?ano)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R

# ── Rose Pine (moon) theme matching nvim ──
set -g @plugin 'rose-pine/tmux'
set -g @rose_pine_variant 'moon'

set -g status-position top
set -g status-left ''
set -g status-left-length 40
set -g status-right '#[fg=#31748f]%H:%M#[default]  #[fg=#c4a7e7]|  #h'
set -g status-right-length 60
set -g status-style bg=#191724,fg=#e0def4
set -g window-status-current-format '#[fg=#191724,bg=#9ccfd8,bold] #I:#W #[default]'
set -g window-status-format '#[fg=#e0def4,bg=#1f1d2e] #I:#W #[default]'
set -g pane-border-style fg=#26233a
set -g pane-active-border-style fg=#c4a7e7
set -g message-style bg=#191724,fg=#e0def4

# ── Plugins (TPM) ──
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'sainnhe/tmux-fzf  '
set -g @plugin 'omerxx/tmux-sessionx'
set -g @resurrect-strategy-nvim 'session'
set -g @sessionx-debug 'off'

# Session persistence: prefix s = save, prefix r = restore
bind-key s run-shell ~/.tmux/plugins/tmux-resurrect/scripts/save.sh
bind-key r run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh

# Initialize TPM — keep at the very bottom
run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 3: Run the config check (already in the harness from Task 1)**

The `scripts/ci/check-config.sh` harness already includes `tmuxcheck tmux/tmux.conf` (with the isolated `-L` socket), so no script change is needed here.

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash scripts/ci/check-config.sh`
Expected: no `FAIL:` lines for `tmux.conf`.

- [ ] **Step 5: Commit**

Run:
```bash
git add tmux/tmux.conf scripts/ci/check-config.sh
git commit -m "feat(tmux): rose-pine theme, vim navigation, session integration"
```

---

### Task 9: Finish and enable the bash prompt

**Files:**
- Modify: `shell/.prompt`

- [ ] **Step 1: Write the failing test**

Run: `grep -q 'set_PS1$' shell/.prompt && echo "already enabled" || echo "NOT enabled yet"`
Expected: `NOT enabled yet` (the current prompt ends with `#set_PS1 # Call the set_PS1 function` and never sets `PROMPT_COMMAND`).

- [ ] **Step 2: Replace `shell/.prompt`**

```bash
# ─────────────────────────────────────────────────────────────
#  bash prompt — git branch, date/time, exit-code indicator
# ─────────────────────────────────────────────────────────────

set -o vi

parse_git_branch() {
    command -v git >/dev/null 2>&1 || return 0
    local branch
    branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)" || return 0
    [[ -n "$branch" ]] && printf ' %s' "$branch"
}

build_PS1() {
    local last=$?

    local when="\[\e[48;5;190;38;5;57m\] ┌ \D{%b-%d %H:%M:%S} ┐ \[\e[0m\]"
    local dir="\[\e[1;36m\]\w\[\e[0m\]"
    local git_branch="\[\e[1;35m\]$(parse_git_branch)\[\e[0m\]"

    if (( last == 0 )); then
        local exit_code="\[\e[38;5;42m\]✓\[\e[0m\]"
    else
        local exit_code="\[\e[38;5;196m\]✗ $last\[\e[0m\]"
    fi

    PS1="$when$dir$git_branch $exit_code "
}

PROMPT_COMMAND=build_PS1
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `grep -q 'PROMPT_COMMAND=build_PS1' shell/.prompt && echo "enabled" && bash -n shell/.prompt && echo "syntax OK"`
Expected: prints `enabled` then `syntax OK`.

- [ ] **Step 4: Commit**

Run:
```bash
git add shell/.prompt
git commit -m "feat(shell): finish and enable prompt with git + exit-code info"
```

---

### Task 10: Expand shell aliases

**Files:**
- Modify: `shell/.alias`

- [ ] **Step 1: Write the failing test**

Run: `grep -q 'alias lazy' shell/.alias && echo "has lazy" || echo "missing lazy"`
Expected: `missing lazy`.

- [ ] **Step 2: Replace `shell/.alias`**

```bash
# Convenience aliases
alias g="git"
alias v="vim"
alias nv="nvim"
alias lazy="lazygit"
alias ls="ls --color=auto"
alias ll="ls -lah"
alias la="ls -A"
alias lt="ls --human-readable --size -1 -S --classify"
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bash -n shell/.alias && grep -q 'alias lazy' shell/.alias && echo "OK"`
Expected: prints `OK`.

- [ ] **Step 4: Commit**

Run:
```bash
git add shell/.alias
git commit -m "feat(shell): expand aliases"
```

---

### Task 11: Add the shared UI library

**Files:**
- Create: `scripts/lib/ui.sh`

- [ ] **Step 1: Write the failing test**

The harness needs a test for the library. Create `scripts/ci/test-ui.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/ui.sh"

info=$(ui::info "hello")
[[ $info == *"[·]"* ]] || { echo "FAIL: info"; exit 1; }
success=$(ui::success "ok")
[[ $success == *"[✓]"* ]] || { echo "FAIL: success"; exit 1; }
warn=$(ui::warn "careful")
[[ $warn == *"[!]"* ]] || { echo "FAIL: warn"; exit 1; }
err=$(ui::error "boom" 2>&1)
[[ $err == *"[✗]"* ]] || { echo "FAIL: error"; exit 1; }
section=$(ui::section "Section")
[[ $section == *"───"* ]] || { echo "FAIL: section"; exit 1; }
echo "ui tests PASS"
```

Run: `bash scripts/ci/test-ui.sh 2>&1; echo "exit=$?"`
Expected: prints the sourcing error (`lib/ui.sh` not found) and a non-zero exit — the test fails because `ui.sh` doesn't exist yet.

- [ ] **Step 2: Create `scripts/lib/ui.sh`**

```bash
#!/usr/bin/env bash
# Shared pretty-output helpers for the dotfiles installer.
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/../lib/ui.sh"

if [[ -t 1 ]]; then
  readonly UI_RESET=$'\e[0m'
  readonly UI_BOLD=$'\e[1m'
  readonly UI_RED=$'\e[31m'
  readonly UI_GREEN=$'\e[32m'
  readonly UI_YELLOW=$'\e[33m'
  readonly UI_MAGENTA=$'\e[35m'
  readonly UI_CYAN=$'\e[36m'
else
  readonly UI_RESET="" UI_BOLD="" UI_RED="" UI_GREEN="" UI_YELLOW="" UI_MAGENTA="" UI_CYAN=""
fi

ui::info()   { echo -e "${UI_CYAN}${UI_BOLD}[·]${UI_RESET} $*"; }
ui::success() { echo -e "${UI_GREEN}${UI_BOLD}[✓]${UI_RESET} $*"; }
ui::warn()   { echo -e "${UI_YELLOW}${UI_BOLD}[!]${UI_RESET} $*"; }
ui::error()  { echo -e "${UI_RED}${UI_BOLD}[✗]${UI_RESET} $*" >&2; }

ui::section() {
  echo
  echo -e "${UI_MAGENTA}${UI_BOLD}─── $* ───${UI_RESET}"
}

# Run a command with a spinner while it works.
ui::spinner() {
  local pid=$1 msg=$2
  local delay=0.1
  local i=0
  local chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  printf '%s ' "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    printf '\b%s' "${chars[i]}"
    i=$(( (i + 1) % ${#chars[@]} ))
    sleep "$delay"
  done
  printf '\b \n'
  wait "$pid"
}
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `bash scripts/ci/test-ui.sh`
Expected: prints `ui tests PASS`.

- [ ] **Step 4: Commit**

Run:
```bash
git add scripts/lib/ui.sh scripts/ci/test-ui.sh
git commit -m "feat(scripts): add shared ui output library"
```

---

### Task 12: Create git-setup.sh

**Files:**
- Create: `scripts/git-setup.sh`

- [ ] **Step 1: Write the failing test**

Run: `HOME=$(mktemp -d) bash scripts/git-setup.sh 2>&1; echo "exit=$?"`
Expected: exit non-zero with `git-setup.sh: No such file or directory`.

- [ ] **Step 2: Create `scripts/git-setup.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"

ui::section "Git aliases"

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist 'log --oneline --decorate --graph'
git config --global alias.d diff

ui::success "Git aliases configured"
```

- [ ] **Step 3: Run the test to verify it passes**

Run:
```bash
HOME=$(mktemp -d) bash scripts/git-setup.sh
HOME=$(mktemp -d)
```
then in a new shell for clarity:
```bash
T="$(mktemp -d)"; HOME="$T" bash scripts/git-setup.sh >/dev/null && \
  HOME="$T" git config --global --get alias.co
```
Expected: prints `checkout`.

- [ ] **Step 4: Commit**

Run:
```bash
git add scripts/git-setup.sh
git commit -m "feat(scripts): add git alias setup (was gitconfig/gitinstall.sh)"
```

---

### Task 13: Create link.sh

**Files:**
- Create: `scripts/link.sh`

- [ ] **Step 1: Write the failing test**

Run: `ls scripts/link.sh 2>&1`
Expected: `ls: cannot access 'scripts/link.sh': No such file or directory`.

- [ ] **Step 2: Create `scripts/link.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"

ui::section "Symlinks"

# Relative repo path -> absolute $HOME destination
links=(
  "nvim              $HOME/.config/nvim"
  "tmux/tmux.conf    $HOME/.tmux.conf"
  "assets/wall.png   $HOME/.config/wall.png"
  "nbrc              $HOME/.nbrc"
  "shell/.prompt     $HOME/.prompt"
  "shell/.alias      $HOME/.alias"
  "obsidian/mycss.css $HOME/.obsidian/snippets/mycss.css"
)

for entry in "${links[@]}"; do
  read -r src dest <<< "$entry"
  src="$DOTFILES/$src"
  if [[ -e "$dest" || -L "$dest" ]]; then
    unlink "$dest" 2>/dev/null || rm -rf "$dest"
    ui::warn "removed existing $dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ui::success "linked $(basename "$src")"
done

ui::section ".bashrc sourcing (idempotent)"

rc="$HOME/.bashrc"
for src in "\$HOME/.prompt" "\$HOME/.alias"; do
  line="source $src"
  if grep -qF -- "$line" "$rc" 2>/dev/null; then
    ui::success "already sourced: $line"
  else
    printf '\n%s\n' "$line" >> "$rc"
    ui::success "added to $rc: $line"
  fi
done
```

- [ ] **Step 3: Run the test to verify it passes in an isolated HOME**

Run:
```bash
T="$(mktemp -d)"
HOME="$T" bash scripts/link.sh
ls -l "$T/.config/nvim" "$T/.tmux.conf" "$T/.nbrc" "$T/.prompt" "$T/.alias" 2>&1
cat "$T/.bashrc"
```
Expected: symlinks listed, `.bashrc` contains both `source` lines, and running it a second time prints `already sourced` (idempotent).

- [ ] **Step 4: Commit**

Run:
```bash
git add scripts/link.sh
git commit -m "feat(scripts): add idempotent symlink + shell rc setup"
```

---

### Task 14: Create bootstrap.sh

**Files:**
- Create: `scripts/bootstrap.sh`

- [ ] **Step 1: Write the failing test**

Run: `ls scripts/bootstrap.sh 2>&1`
Expected: `ls: cannot access 'scripts/bootstrap.sh': No such file or directory`.

- [ ] **Step 2: Create `scripts/bootstrap.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"

if ! command -v pacman >/dev/null 2>&1; then
  ui::error "This installer only supports Arch Linux (pacman)."
  exit 1
fi

PACKAGES=(vim tmux git neovim)

ui::section "Bootstrap — packages"

missing=()
for pkg in "${PACKAGES[@]}"; do
  if pacman -Qi "$pkg" >/dev/null 2>&1; then
    ui::success "$pkg already installed"
  else
    missing+=("$pkg")
  fi
done

if ((${#missing[@]})); then
  if [[ "${BOOTSTRAP_CHECK_ONLY:-0}" == "1" ]]; then
    ui::warn "would install: ${missing[*]} (BOOTSTRAP_CHECK_ONLY=1)"
  else
    ui::info "Installing: ${missing[*]}"
    sudo pacman -S --noconfirm "${missing[@]}"
  fi
else
  ui::info "All packages present."
fi

ui::section "Bootstrap — TPM"

if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
  ui::success "TPM already installed"
else
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  ui::success "TPM installed"
fi
```

- [ ] **Step 3: Run the test to verify it passes (non-destructive)**

Run:
```bash
bash -n scripts/bootstrap.sh && echo "syntax OK"
T="$(mktemp -d)"
HOME="$T" BOOTSTRAP_CHECK_ONLY=1 bash scripts/bootstrap.sh
ls -d "$T/.tmux/plugins/tpm"
```
Expected: `syntax OK`, package check sections print, TPM is cloned into the temp HOME, and **no** `sudo pacman` ran. (The `BOOTSTRAP_CHECK_ONLY=1` env guard makes the package-install path print-only so the plan can be verified without touching the system.)

- [ ] **Step 4: Commit**

Run:
```bash
git add scripts/bootstrap.sh
git commit -m "feat(scripts): add pacman + TPM bootstrap"
```

---

### Task 15: Rewrite install.sh as the pretty driver

**Files:**
- Modify: `scripts/install.sh`

- [ ] **Step 1: Write the failing test**

Run: `bash scripts/install.sh --help 2>&1 | grep -q 'dry-run' && echo "has help" || echo "no help yet"`
Expected: `no help yet`.

- [ ] **Step 2: Replace `scripts/install.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/ui.sh"

SHOW_HELP=false
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: bash install.sh [--dry-run] [--help]

Dotfiles installer steps:
  bootstrap   install packages (pacman) and TPM
  link        create symlinks and shell rc entries
  git-setup   configure git aliases

Options:
  --dry-run   preview what would be done (apply no changes)
  --help      show this help
EOF
}

step() {
  local name=$1 label=$2
  if "$DRY_RUN"; then
    ui::section "[dry-run] $label"
    ui::info "would run: scripts/$name.sh"
  else
    ui::section "$label"
    bash "$SCRIPT_DIR/$name.sh"
  fi
}

for arg in "$@"; do
  case "$arg" in
    --help)    SHOW_HELP=true ;;
    --dry-run) DRY_RUN=true ;;
    *) ui::error "unknown option: $arg"; usage; exit 1 ;;
  esac
done

if "$SHOW_HELP"; then
  usage
  exit 0
fi

ui::info "Starting dotfiles installer..."
step bootstrap "Bootstrap (packages + TPM)"
step link      "Link config files"
step git-setup "Configure git aliases"
ui::success "Done."
```

- [ ] **Step 3: Run the test to verify it passes**

Run:
```bash
bash -n scripts/install.sh && echo "syntax OK"
bash scripts/install.sh --help | grep -- '--dry-run'
bash scripts/install.sh --dry-run
```
Expected: `syntax OK`, the `--dry-run` line, and three `[dry-run]` sections with no changes applied.

- [ ] **Step 4: Commit**

Run:
```bash
git add scripts/install.sh
git commit -m "feat(scripts): rewrite installer as pretty driver with --dry-run/--help"
```

---

### Task 16: Rewrite the README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write the failing test**

Run: `grep -q "badge" README.md && echo "has badges" || echo "no badges yet"`
Expected: `no badges yet`.

- [ ] **Step 2: Replace `README.md`**

````markdown
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
````

- [ ] **Step 3: Run the test to verify it passes**

Run: `grep -q "badge" README.md && echo "has badges" && grep -q "install.sh --dry-run" README.md && echo "has install section"`
Expected: prints `has badges` and `has install section`.

- [ ] **Step 4: Commit**

Run:
```bash
git add README.md
git commit -m "docs: rewrite professional README"
```

---

### Task 17: Regenerate lazy-lock and final verification

**Files:**
- Modify: `nvim/lazy-lock.json` (regenerated by Lazy)
- No code changes to new plugins unless verification reveals an error

- [ ] **Step 1: Regenerate lazy-lock.json**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa"
```
Expected: locks for lualine.nvim, bufferline.nvim, vim-tmux-navigator (and dependencies) appear in `nvim/lazy-lock.json`.

- [ ] **Step 2: Run the full test suite**

Run:
```bash
bash scripts/ci/check-config.sh; echo "config exit=$?"
bash scripts/ci/test-ui.sh; echo "ui exit=$?"
bash -n scripts/*.sh shell/.prompt shell/.alias; echo "syntax exit=$?"
```
Expected: all exit `0` with no `FAIL:` lines.

- [ ] **Step 3: Verify the whole config boots with the real runtime path**

Run: `nvim --headless -c 'qa'`
Expected: exits cleanly with no `E5`/`E5`… or `E5108` errors printed.

- [ ] **Step 4: Smoke-test the installer end-to-end off a real HOME**

Run:
```bash
T="$(mktemp -d)"
HOME="$T" BOOTSTRAP_CHECK_ONLY=1 bash scripts/bootstrap.sh 2>&1 | tail -3
HOME="$T" bash scripts/link.sh 2>&1 | tail -5
HOME="$T" bash scripts/git-setup.sh 2>&1 | tail -2
ls -l "$T/.config/nvim" "$T/.tmux.conf" "$T/.prompt" 2>&1
```
Expected: `bootstrap` runs its pacman checks in check-only mode (TPM installed into the temp HOME), `link` creates the symlinks, `git-setup` prints success, and the three symlinks exist in the temp HOME.

- [ ] **Step 5: Commit**

Run:
```bash
git add nvim/lazy-lock.json scripts/
git commit -m "chore: regenerate lazy-lock and finalize installer verification"
```
