#!/usr/bin/env bash
# Uninstall all Cursor extensions.
# Run standalone before import if you want a clean slate.
#
# Usage: cursor-extensions-clean.sh

set -euo pipefail

CURSOR_CLI=""
if command -v cursor &>/dev/null; then
  CURSOR_CLI="cursor"
elif [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
  CURSOR_CLI="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
fi

if [[ -z "$CURSOR_CLI" ]]; then
  echo "Error: 'cursor' CLI not found. Install it in Cursor:"
  echo "  Command Palette (Cmd+Shift+P) → 'Shell Command: Install cursor command in PATH'"
  exit 1
fi

echo "Uninstalling all extensions..."
count=0
while read -r ext; do
  [[ -z "${ext// }" ]] && continue
  echo "  → $ext"
  "$CURSOR_CLI" --uninstall-extension "$ext" 2>/dev/null || true
  ((count++)) || true
done < <("$CURSOR_CLI" --list-extensions 2>/dev/null || true)

echo ""
echo "Removed $count extension(s). Restart Cursor to apply."
