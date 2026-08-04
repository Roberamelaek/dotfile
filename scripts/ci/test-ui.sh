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
