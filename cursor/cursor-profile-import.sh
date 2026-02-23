#!/usr/bin/env bash
# Import Cursor profile from a tarball created by cursor-profile-export.sh
# Run on new device after transferring the tarball.
#
# Imports only: User settings (settings.json, keybindings.json) and extensions.
# Skills are NOT imported (use skillsync for that); this avoids overwriting
# skills managed by agents-skills/.
#
# Usage: cursor-profile-import.sh TARBALL
#   TARBALL  Path to the exported cursor-profile-*.tar.gz file

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 TARBALL"
  echo "  TARBALL  Path to cursor-profile-*.tar.gz from cursor-profile-export.sh"
  exit 1
fi

TARBALL="$1"
if [[ ! -f "$TARBALL" ]]; then
  echo "Error: File not found: $TARBALL"
  exit 1
fi

CURSOR_USER="${HOME}/Library/Application Support/Cursor/User"
EXTRACT_DIR="${TMPDIR:-/tmp}/cursor-profile-import-$$"
trap 'rm -rf "$EXTRACT_DIR"' EXIT

mkdir -p "$EXTRACT_DIR"
echo "Extracting $TARBALL..."
tar -xzf "$TARBALL" -C "$EXTRACT_DIR"

IMPORTED_USER=0
EXT_COUNT=0

# ─── User settings & keybindings ───
if [[ -d "$EXTRACT_DIR/User" ]]; then
  echo "Importing User settings..."
  mkdir -p "$CURSOR_USER"
  cp -a "$EXTRACT_DIR/User/." "$CURSOR_USER/"
  IMPORTED_USER=1
fi

# ─── Extensions ───
CURSOR_CLI=""
if command -v cursor &>/dev/null; then
  CURSOR_CLI="cursor"
elif [[ -x "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" ]]; then
  CURSOR_CLI="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
fi

if [[ -f "$EXTRACT_DIR/extensions.txt" && -s "$EXTRACT_DIR/extensions.txt" ]]; then
  echo "Installing extensions..."
  if [[ -z "$CURSOR_CLI" ]]; then
    echo "  Warning: 'cursor' CLI not found. Install it in Cursor:"
    echo "    Command Palette (Cmd+Shift+P) → 'Shell Command: Install cursor command in PATH'"
    echo "  Or add to PATH: /Applications/Cursor.app/Contents/Resources/app/bin"
    echo "  Then re-run this script. Or install manually from $EXTRACT_DIR/extensions.txt"
    EXT_COUNT=$(grep -cv '^[[:space:]]*$' "$EXTRACT_DIR/extensions.txt" 2>/dev/null || echo 0)
  else
    echo "  Tip: Quit Cursor first if installs fail."
    while read -r ext; do
      [[ -z "${ext// }" ]] && continue
      echo -n "  → $ext ... "
      if "$CURSOR_CLI" --install-extension "$ext" 2>&1; then
        echo "ok"
      else
        echo "FAILED (check output above)"
      fi
      ((EXT_COUNT++)) || true
    done < "$EXTRACT_DIR/extensions.txt"
  fi
fi

echo ""
echo "Profile imported successfully."
echo "  User settings: $([[ $IMPORTED_USER -eq 1 ]] && echo 'yes' || echo 'no')"
echo "  Extensions:     $EXT_COUNT"
echo ""
echo "Restart Cursor to apply settings and extensions."
