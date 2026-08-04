# tmux Window/Pane Bash Shortcuts (`nw`/`np`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `nw`/`np` bash functions that create and name tmux windows/panes, plus tmux pane-border titles, so creating a named window or pane is a one-line command from the bash prompt (inside or outside tmux).

**Architecture:** Two `nw()`/`np()` functions appended to `shell/.alias` (already sourced into every bash prompt by `link.sh`). They branch on the `TMUX` env var: inside tmux they target the current session; outside they bootstrap a new named session and attach. A `pane-border-status top` + `pane-border-format` change in `tmux/tmux.conf` makes pane titles visible.

**Tech Stack:** bash, tmux (3.3+)

**Spec:** `docs/superpowers/specs/2026-08-04-tmux-window-pane-shortcuts-design.md`

---

## File structure

- `tmux/tmux.conf` (Modify) — add pane-border-status/format so pane names render.
- `shell/.alias` (Modify) — append `nw()` and `np()` functions.

No new files. `install.sh`/`link.sh` already wire `~/.alias` into bash.

---

### Task 1: Draw pane titles on tmux borders

**Files:**
- Modify: `tmux/tmux.conf` (insert after the `pane-active-border-style` line)

- [ ] **Step 1: Write the failing test**

Run: `grep -q 'pane-border-status top' tmux/tmux.conf && echo "already set" || echo "not set"`
Expected: `not set`.

- [ ] **Step 2: Add the pane border lines**

Insert these two lines into `tmux/tmux.conf` immediately after the existing
`set -g pane-active-border-style fg=#c4a7e7` line:

```tmux
set -g pane-border-status top
set -g pane-border-format '#[bold]#{pane_title}#[default]'
```

(The format line is required — the default format only renders the pane index,
so without it `np`'s pane names would not appear on the border.)

- [ ] **Step 3: Run the test to verify it passes**

Run: `grep -q 'pane-border-status top' tmux/tmux.conf && grep -q "pane-border-format '#\[bold\]#{pane_title}#\[default\]'" tmux/tmux.conf && echo "border lines present"`
Expected: `border lines present`.

- [ ] **Step 4: Verify the config still parses and boots**

Run:
```bash
bash scripts/ci/check-config.sh; echo "config exit=$?"
tmux -L "$(whoami)-manual" -f tmux/tmux.conf new-session -d -s t && \
  tmux -L "$(whoami)-manual" show-options -g pane-border-status pane-border-format && \
  tmux -L "$(whoami)-manual" kill-server
```
Expected: `config exit=0`, and `show-options` prints `pane-border-status top` +
`pane-border-format #[bold]#{pane_title}#[default]`, no error. (Do NOT read the
options back via `#{pane_border_status}`/`#{pane_border_format}` format
expansions — those variables do not exist in tmux; use `show-options`.)

- [ ] **Step 5: Commit**

```bash
git add tmux/tmux.conf
git commit -m "feat(tmux): draw pane titles on pane borders"
```

---

### Task 2: Add `nw` and `np` bash functions to `shell/.alias`

**Files:**
- Modify: `shell/.alias` (append at end, keep trailing newline)

- [ ] **Step 1: Write the failing test**

Run: `grep -q '^nw()' shell/.alias && echo "has nw" || echo "missing nw"`
Expected: `missing nw`.

- [ ] **Step 2: Append the functions**

Append the following block to the end of `shell/.alias` (file keeps a trailing
newline — verify with `tail -c 1 shell/.alias | od -c | head -1`, last byte
`\n`):

```bash

# ── tmux functions ──
nw() {
  local session="${1:-$(basename "$PWD")}"
  local window="${2:-$session}"
  if [[ -n "${TMUX:-}" ]]; then
    tmux new-window -n "$window"
  else
    tmux new-session -d -s "$session" -n "$window"
    tmux attach-session -t "$session"
  fi
}

np() {
  local dir=""
  while [[ "${1:-}" == -h || "${1:-}" == -v ]]; do
    dir+="$1"; shift
  done
  dir="${dir:--h}"
  if [[ -n "${TMUX:-}" ]]; then
    local name="${1:-$(basename "$PWD")}"
    local pane
    pane="$(tmux split-window "$dir" -P -F '#{pane_id}')"
    tmux rename-pane -t "$pane" "$name"
  else
    local session="${1:-$(basename "$PWD")}"
    local window="${2:-$session}"
    tmux new-session -d -s "$session" -n "$window"
    tmux attach-session -t "$session"
  fi
}
```

Notes on behavior: `nw foo` inside tmux creates window `foo`; `nw proj code`
outside tmux creates session `proj` with window `code` then attaches; `nw` with
no args names both from the current directory basename. `np -v api` splits
vertically naming the new pane `api`; `np api` (no flag) splits horizontally.
Pythagorean note: `np -h -v ...` (two flags) is unsupported — at most one flag.

- [ ] **Step 3: Run the test to verify it passes (syntax + presence)**

Run:
```bash
bash -n shell/.alias && echo "syntax OK"
grep -q '^nw()' shell/.alias && grep -q '^np()' shell/.alias && echo "functions present"
```
Expected: `syntax OK` then `functions present`.

- [ ] **Step 4: Test `nw` inside tmux (named window)**

Run:
```bash
SOCK="dev$$"
tmux -L "$SOCK" new-session -d -s t -n base
tmux -L "$SOCK" send-keys -t t 'source /home/roba/.dotfiles/shell/.alias && nw foo' Enter
sleep 0.4
tmux -L "$SOCK" list-windows -F '#{window_name}'
tmux -L "$SOCK" kill-server
```
Expected: prints `base` then `foo` (window `foo` created in session `t`).

- [ ] **Step 5: Test `nw` default name (directory basename)**

Run:
```bash
SOCK="dev$$"
tmux -L "$SOCK" new-session -d -s t -n base
tmux -L "$SOCK" send-keys -t t 'cd /tmp && source /home/roba/.dotfiles/shell/.alias && nw' Enter
sleep 0.4
tmux -L "$SOCK" list-windows -F '#{window_name}'
tmux -L "$SOCK" kill-server
```
Expected: prints `base` then `tmp`.

- [ ] **Step 6: Test `nw` outside tmux (distinct session/window names)**

Run:
```bash
TMPD="$(mktemp -d)"
TMUX_TMPDIR="$TMPD" bash -c 'source /home/roba/.dotfiles/shell/.alias; nw proj code' 2>/dev/null
TMUX_TMPDIR="$TMPD" tmux list-sessions -F '#{session_name}'
TMUX_TMPDIR="$TMPD" tmux list-windows -t proj -F '#{window_name}'
TMUX_TMPDIR="$TMPD" tmux kill-server
```
Expected: `proj` (session) and `code` (window). The `attach-session` inside the
function fails with `not a tty` in this headless test (stderr suppressed) but
runs AFTER the session/window are created, so the names are still verified.
Note: with `2>/dev/null` the `nw proj code` line's exit status is from bash; do
not use `set -e` for this step.

- [ ] **Step 7: Test `np` inside tmux (horizontal default, pane name set)**

Run:
```bash
SOCK="dev$$"
tmux -L "$SOCK" new-session -d -s t -n base
tmux -L "$SOCK" send-keys -t t 'source /home/roba/.dotfiles/shell/.alias && np api' Enter
sleep 0.4
tmux -L "$SOCK" list-panes -F '#{pane_title}' | grep -x api
tmux -L "$SOCK" list-panes -F '#{pane_top}'
tmux -L "$SOCK" kill-server
```
Expected: `grep` prints `api` (the new pane's title); `list-panes -F
'#{pane_top}'` prints two identical row numbers (horizontal split → panes side
by side, same top).

- [ ] **Step 8: Test `np -v` (vertical split)**

Run:
```bash
SOCK="dev$$"
tmux -L "$SOCK" new-session -d -s t -n base
tmux -L "$SOCK" send-keys -t t 'source /home/roba/.dotfiles/shell/.alias && np -v db' Enter
sleep 0.4
tmux -L "$SOCK" list-panes -F '#{pane_title}' | grep -x db
tmux -L "$SOCK" list-panes -F '#{pane_left}'
tmux -L "$SOCK" kill-server
```
Expected: `grep` prints `db` (the new pane's title); `list-panes -F
'#{pane_left}'` prints two identical column numbers (vertical split → panes
stacked, same left).

- [ ] **Step 9: Commit**

```bash
git add shell/.alias
git commit -m "feat(shell): add nw/np tmux window and pane shortcuts"
```

---

### Task 3: End-to-end verification

**Files:**
- None (verification only; commit only if something unexpected changed)

- [ ] **Step 1: Run the full test suite**

Run:
```bash
bash scripts/ci/check-config.sh; echo "config exit=$?"
bash scripts/ci/test-ui.sh; echo "ui exit=$?"
bash -n shell/.alias shell/.prompt scripts/*.sh; echo "syntax exit=$?"
```
Expected: `config exit=0`, `ui exit=0` (ui tests PASS), `syntax exit=0`.

- [ ] **Step 2: End-to-end chained flow (`nw foo && np bar` in one line)**

Run:
```bash
SOCK="e2e$$"
tmux -L "$SOCK" new-session -d -s t -n base
tmux -L "$SOCK" send-keys -t t 'source /home/roba/.dotfiles/shell/.alias && nw foo && np bar' Enter
sleep 0.5
tmux -L "$SOCK" list-windows -F '#{window_name}'
tmux -L "$SOCK" list-panes -F '#{pane_title}' | grep -x bar
tmux -L "$SOCK" kill-server
```
Expected: windows list shows `base`, `foo`; the grep prints `bar` (one line)
because window `foo` was focused when the chained `np bar` split it.

- [ ] **Step 3: Confirm tree clean and no real HOME touched**

Run:
```bash
git status --short
```
Expected: empty (or only whatever Task 2 step verified; if anything changed
unexpectedly, do NOT commit blindly — report it). Confirm `~/.tmux` and real
sessions were not modified (all tests above used isolated sockets/TMPDIRs).

## Self-review notes

- Specced behaviors → tasks: border titles (Task 1), `nw` inside/outside +
  two-arg + basename default + chaining (Task 2 steps 3-6, Task 3 step 2), `np`
  `-h`/`-v` flags + pane rename + basename default (Tasks 2 step 7-8).
- No placeholders; all test commands are exact with expected output.
- Names consistent: `nw`/`np`, `session`, `window`, `name`, `dir`/`pane`.
- Real `~/.bashrc`, `~/.alias` symlink, and `~/.tmux` are never touched; all
  tmux tests run against `-L`-specified sockets or `TMUX_TMPDIR` servers.