#!/usr/bin/env bash
# Import Cursor profile from a tarball created by cursor-profile-export.sh
# Run on new device after transferring the tarball.
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
CURSOR_EXTENSIONS="${HOME}/.cursor/extensions"
CURSOR_SKILLS="${HOME}/.cursor/skills"
EXTRACT_DIR="${TMPDIR:-/tmp}/cursor-profile-import-$$"
trap 'rm -rf "$EXTRACT_DIR"' EXIT

mkdir -p "$EXTRACT_DIR"
echo "Extracting $TARBALL..."
tar -xzf "$TARBALL" -C "$EXTRACT_DIR"

# ─── User settings & keybindings ───
if [[ -d "$EXTRACT_DIR/User" ]]; then
  echo "Importing User settings..."
  mkdir -p "$CURSOR_USER"
  cp -a "$EXTRACT_DIR/User/." "$CURSOR_USER/"
fi

# ─── Skills ───
if [[ -d "$EXTRACT_DIR/skills" ]]; then
  echo "Importing skills..."
  mkdir -p "$(dirname "$CURSOR_SKILLS")"
  rm -rf "$CURSOR_SKILLS"
  mv "$EXTRACT_DIR/skills" "$CURSOR_SKILLS"
fi

# ─── Extensions ───
if [[ -f "$EXTRACT_DIR/extensions.txt" && -s "$EXTRACT_DIR/extensions.txt" ]]; then
  echo "Installing extensions..."
  mkdir -p "$CURSOR_EXTENSIONS"
  if command -v cursor &>/dev/null; then
    while read -r ext; do
      [[ -z "$ext" ]] && continue
      echo "  → $ext"
      cursor --install-extension "$ext" 2>/dev/null || true
    done < "$EXTRACT_DIR/extensions.txt"
  else
    echo "  Warning: 'cursor' CLI not found. Install it via Cursor:"
    echo "    Command Palette → Shell Command: Install 'cursor' command"
    echo "  Then run: cursor-profile-import.sh $TARBALL"
    echo "  Or install extensions manually from $EXTRACT_DIR/extensions.txt"
  fi
fi

echo ""
echo "Import complete. Restart Cursor to apply settings and extensions."
