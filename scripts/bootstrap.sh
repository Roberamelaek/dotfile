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
