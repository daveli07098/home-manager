#!/usr/bin/env bash
# Copy rules (*.mdc) into Cursor global "Rules for AI" (state.vscdb).
# Run when you want global Cursor to use the rules from this folder.
#
# Usage: apply-agents-rules.sh [RULES_DIR]
#   RULES_DIR  Default: this script's directory (rules/)
#
# Note: Quit Cursor before running, or it may overwrite the change on exit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="${1:-$SCRIPT_DIR}"
STATE_DB="${HOME}/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
KEY="aicontext.personalContext"

if [[ ! -d "$RULES_DIR" ]]; then
  echo "Error: RULES_DIR not found: $RULES_DIR"
  exit 1
fi

shopt -s nullglob
mdc_files=("$RULES_DIR"/*.mdc)
if [[ ${#mdc_files[@]} -eq 0 ]]; then
  echo "Error: No *.mdc files in $RULES_DIR"
  exit 1
fi

echo "Concatenating ${#mdc_files[@]} rule(s) from $RULES_DIR..."
content=""
for f in $(printf '%s\n' "${mdc_files[@]}" | sort); do
  content+=$'\n\n'
  content+="$(cat "$f")"
done
content="${content#[$'\n\n']}"

STATE_DIR="$(dirname "$STATE_DB")"
if [[ ! -d "$STATE_DIR" ]]; then
  echo "Error: Cursor User dir not found: $STATE_DIR"
  exit 1
fi

echo "Writing to global Cursor rules (state.vscdb)..."
python3 -c "
import sqlite3
import sys
data = sys.stdin.read()
conn = sqlite3.connect(sys.argv[1])
conn.execute('INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)', (sys.argv[2], data))
conn.commit()
conn.close()
" "$STATE_DB" "$KEY" <<< "$content"

echo "Done. Restart Cursor to use the new global rules."
