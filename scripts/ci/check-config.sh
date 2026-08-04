#!/usr/bin/env bash
# Sandboxed checks for every lua file under nvim/ and for tmux.conf.
# Compiles each lua file with loadfile (no execution, no plugin downloads).
# Usage: bash scripts/ci/check-config.sh  (run from repo root)
set -u
shopt -s nullglob
cd "$(dirname "$0")/../.." || exit 1
fail=0

nlua() {
  if ! command -v nvim >/dev/null 2>&1; then
    echo "SKIP: nvim not installed"
    return 0
  fi
  nvim --headless -u NONE -c "lua assert(loadfile('$1'))" -c 'qa' 2>&1 \
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
