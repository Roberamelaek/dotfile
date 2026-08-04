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
