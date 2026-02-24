#!/usr/bin/env bash
# Export Cursor profile (settings, keybindings, extensions list, skills, rules) to a tarball.
# Run on source device. Transfer the tarball to new device and run cursor-profile-import.sh
#
# Usage: cursor-profile-export.sh [OUTPUT_FILE]
#   OUTPUT_FILE  Default: cursor/export/cursor-profile-$(date +%Y%m%d).tar.gz

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_OUTPUT_DIR="${SCRIPT_DIR}/export"
OUTPUT="${1:-${EXPORT_OUTPUT_DIR}/cursor-profile-$(date +%Y%m%d).tar.gz}"
EXPORT_DIR="${TMPDIR:-/tmp}/cursor-profile-export-$$"
trap 'rm -rf "$EXPORT_DIR"' EXIT

CURSOR_USER="${HOME}/Library/Application Support/Cursor/User"
CURSOR_EXTENSIONS="${HOME}/.cursor/extensions"
CURSOR_SKILLS="${HOME}/.cursor/skills"

mkdir -p "$EXPORT_DIR"
mkdir -p "$EXPORT_OUTPUT_DIR"

# ─── Settings & keybindings ───
if [[ -d "$CURSOR_USER" ]]; then
  echo "Exporting User settings..."
  cp -R "$CURSOR_USER" "$EXPORT_DIR/"
else
  echo "Warning: $CURSOR_USER not found (skipping)"
fi

# ─── Skills ───
if [[ -d "$CURSOR_SKILLS" ]]; then
  echo "Exporting skills..."
  cp -R "$CURSOR_SKILLS" "$EXPORT_DIR/"
else
  echo "Warning: $CURSOR_SKILLS not found (skipping)"
fi

# ─── Repo rules (for import → global) ───
REPO_RULES="${SCRIPT_DIR}/../rules"
if [[ -d "$REPO_RULES" ]]; then
  echo "Exporting rules..."
  cp -R "$REPO_RULES" "$EXPORT_DIR/"
fi

# ─── Global rules backup (from state.vscdb) ───
STATE_DB="${CURSOR_USER}/globalStorage/state.vscdb"
if [[ -f "$STATE_DB" ]]; then
  echo "Exporting global rules backup..."
  sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key = 'aicontext.personalContext';" 2>/dev/null > "$EXPORT_DIR/global-rules.txt" || true
  [[ ! -s "$EXPORT_DIR/global-rules.txt" ]] && rm -f "$EXPORT_DIR/global-rules.txt"
fi

# ─── Extensions list ───
if command -v cursor &>/dev/null; then
  echo "Exporting extensions list (via cursor CLI)..."
  cursor --list-extensions 2>/dev/null > "$EXPORT_DIR/extensions.txt" || true
fi
if [[ ! -s "$EXPORT_DIR/extensions.txt" && -d "$CURSOR_EXTENSIONS" ]]; then
  echo "Exporting extensions list (from extensions folder)..."
  for d in "$CURSOR_EXTENSIONS"/[^.]*; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    # Format: publisher.name-version -> publisher.name (strip -X.Y.Z suffix)
    echo "$name" | sed -E 's/-[0-9][0-9.]*(-[a-z0-9-]*)?$//' >> "$EXPORT_DIR/extensions.txt"
  done
  sort -u "$EXPORT_DIR/extensions.txt" -o "$EXPORT_DIR/extensions.txt"
fi

# ─── Create tarball ───
echo "Creating $OUTPUT..."
tar -czf "$OUTPUT" -C "$EXPORT_DIR" .

echo ""
echo "Exported to $OUTPUT"
echo "Transfer this file to the new device and run:"
echo "  cursor-profile-import.sh $OUTPUT"
