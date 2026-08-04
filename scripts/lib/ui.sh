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
