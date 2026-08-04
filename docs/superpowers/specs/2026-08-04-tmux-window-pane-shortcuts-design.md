# Design: tmux window/pane bash shortcuts (`nw` / `np`)

Date: 2026-08-04
Status: Approved (awaiting user review)

## Goal

Make creating and naming tmux windows/panes fast from the bash prompt, both
before and inside tmux, using short commands instead of long tmux commands.

## Decisions

1. **Bash functions, not tmux binds.** `nw` and `np` are bash functions in
   `shell/.alias` (already sourced into every bash prompt via `link.sh`), so
   they work before tmux is open and from inside any pane.
2. **Inside/outside detection.** The `TMUX` environment variable determines
   behavior: inside tmux → operate on the current session; outside → start a
   new named session and attach.
3. **Default name.** When no name argument is given, both commands use the
   basename of the current directory (`$(basename "$PWD")`).
4. **Distinct session/window names (outside tmux).** `nw [session] [window]`
   accepts up to two names: outside tmux the first names the session and the
   second names the window (`tmux new-session -s <session> -n <window>`). One
   argument names both; none uses the directory basename for both. Inside
   tmux only the window name matters (see `nw` below).
4. **Pane split direction.** `np` splits horizontally (right half, matching the
   `C-a |` binding) by default; `-h` / `-v` flags override.
5. **Visible pane names.** `tmux.conf` gains `set -g pane-border-status top` so
   pane titles (set by `np`) render on each pane border. Styling remains within
   the existing rose-pine colors.

## Behavior

### `nw [session] [window]` — new window (or session + window)

- **Inside tmux:** `tmux new-window -n "<window>"`. The window name is the
  second argument if given, else the first argument, else the directory
  basename (the session name is irrelevant inside tmux). New window inherits
  the current pane's working directory (tmux default) and is selected.
- **Outside tmux:** `tmux new-session -d -s "<session>" -n "<window>"` then
  `tmux attach-session -t "<session>"`. Session name = first argument (or
  basename), window name = second argument (or first, or basename). Detach/exit
  returns to the bash prompt.

### `np [-h|-v] [name]` — new pane

- **Inside tmux:** captures the new pane id via
  `tmux split-window <-h|-v> -P -F '#{pane_id}'`, then
  `tmux rename-pane -t "<id>" "<name>"`. The new pane's title is the name and
  is drawn on the pane border (`.top`). Transition to the new pane: tmux moves
  focus to it (default split behavior). Pane name = first argument (or
  basename).
- **Outside tmux:** identical bootstrap to `nw` (session + window named from
  the arguments as above, attach). No split is attempted.

### Argument handling

- `nw`: `$1` = session name (outside tmux only), `$2` = window name; window
  name falls back to `$1`, then to the basename of `$PWD`.
- `np`: consumes `-h`/`-v` first (any position is not supported — flags must
  precede the name), then `$1` = pane name (within tmux) or the session name
  (outside tmux, where `$2` = window name, falling back as `nw` does).
- No name → basename of `$PWD`.
- Names may contain spaces; both the shell functions and tmux quote them
  (`-n "$window"`).

### One-line chaining

- `nw foo && np bar` works in one line: `nw` creates and selects window `foo`,
  then `np` splits that window and names the pane `bar`.
- Caveat: outside tmux, `nw`'s `attach-session` blocks until detach, so a
  chained `np` only runs afterward.

## Files changed

- `shell/.alias` — add `nw()` and `np()` functions (Append after existing
  aliases; keep the file's `# ── ... ──` comment-grouping style, e.g. a
  `# ── tmux functions ──` header).
- `tmux/tmux.conf` — add `set -g pane-border-status top` (in the theme/status
  section, after `pane-border-style`).

## Testing

- `bash -n shell/.alias`.
- Isolated tmux socket (`tmux -L <unique>`), temp `TMUX` env: in a session,
  run the functions and assert:
  - `tmux list-windows -F '#{window_name}'` contains the new window name.
  - `tmux list-panes -F '#{pane_title}'` contains the new pane title.
  - Default-name case resolves to the directory basename.
  - `np -v` / `np -h` honor the direction flag (assert split layout via
    `#{pane_id}`.) ordering or layout string).
- Outside-tmux case: fresh session is created and attached; verify session name
  and window name via `tmux list-sessions`/`list-windows` on the default socket
  (using a temp `$TMUX_TMPDIR` or unique socket, then kill-server). Include a
  two-argument case (`nw proj code`) asserting session `proj` and window `code`.
- `bash scripts/ci/check-config.sh` still exit 0 (parses the modified
  `tmux.conf`).
- Real-env smoke: `tmux -L (whoami)-manual -f tmux/tmux.conf new-session -d`
  boots without error.

## Out of scope

- Renaming existing windows/panes (not requested).
- Session pickers / extra session management beyond the `nw`/`np` bootstrap
  (tmux-sessionx already covers that).
- Changing existing create bindings (`C-a c`, `C-a |`, `C-a -`).
- Pane layout presets or sizes.
