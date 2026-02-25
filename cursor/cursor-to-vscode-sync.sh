#!/usr/bin/env bash
# Sync Cursor profile (settings + extensions) to VS Code so both editors stay aligned.
# Rules and skills are Cursor-only and have no VS Code equivalent.
#
# Usage: cursor-to-vscode-sync.sh [--dry-run]
#   --dry-run  Print what would be done, do not copy or install.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_USER="${HOME}/Library/Application Support/Cursor/User"
CODE_USER="${HOME}/Library/Application Support/Code/User"
DRY_RUN=false

for arg in "$@"; do
  [[ "$arg" == "--dry-run" ]] && DRY_RUN=true
done

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# ─── Settings & keybindings ───
if [[ ! -d "$CURSOR_USER" ]]; then
  echo "Warning: Cursor User dir not found: $CURSOR_USER (skipping settings)"
else
  mkdir -p "$CODE_USER"
  for f in settings.json keybindings.json; do
    if [[ -f "$CURSOR_USER/$f" ]]; then
      echo "Syncing $f → VS Code..."
      run cp -a "$CURSOR_USER/$f" "$CODE_USER/$f"
    fi
  done
fi

# ─── Extensions ───
CURSOR_CLI=""
if command -v cursor &>/dev/null; then
  CURSOR_CLI="cursor"
elif [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
  CURSOR_CLI="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
fi

CODE_CLI=""
if command -v code &>/dev/null; then
  CODE_CLI="code"
fi

if [[ -z "$CURSOR_CLI" ]]; then
  echo "Warning: 'cursor' CLI not found; cannot list extensions. Install in Cursor: Command Palette → 'Shell Command: Install cursor command in PATH'"
elif [[ -z "$CODE_CLI" ]]; then
  echo "Warning: 'code' CLI not found; cannot install extensions in VS Code. Install in VS Code: Command Palette → 'Shell Command: Install code command in PATH'"
else
  echo "Syncing extensions (Cursor → VS Code)..."
  installed=0
  failed=0
  while read -r ext_id; do
    [[ -z "${ext_id// }" ]] && continue
    ext_id="$(echo "$ext_id" | sed -E 's/-[0-9][0-9.]*(-[a-z0-9-]*)?$//')"
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [dry-run] would install: $ext_id"
      ((installed++)) || true
    else
      if "$CODE_CLI" --list-extensions 2>/dev/null | grep -qFx "$ext_id"; then
        echo "  ✓ $ext_id (already installed)"
      else
        echo -n "  → $ext_id ... "
        if "$CODE_CLI" --install-extension "$ext_id" --force 2>/dev/null; then
          echo "ok"
          ((installed++)) || true
        else
          echo "FAILED"
          ((failed++)) || true
        fi
      fi
    fi
  done < <("$CURSOR_CLI" --list-extensions 2>/dev/null || true)
  echo "Extensions: $installed installed, $failed failed (VS Code may not have all Cursor-only extensions)."
fi

echo ""
echo "Done. Restart VS Code to apply settings."
echo "Note: Rules and skills are Cursor-only; they are not synced to VS Code."
