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
