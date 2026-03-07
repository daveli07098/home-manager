#!/usr/bin/env bash
# Sync Cursor profile (settings, extensions, skills, rules → ~/.copilot/skills) to VS Code.
#
# Usage: cursor-to-vscode-sync.sh [--dry-run]
#   --dry-run  Print what would be done, do not copy or install.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="${SCRIPT_DIR}/../rules"
CURSOR_USER="${HOME}/Library/Application Support/Cursor/User"
CURSOR_SKILLS="${HOME}/.cursor/skills"
CODE_USER="${HOME}/Library/Application Support/Code/User"
COPILOT_SKILLS="${HOME}/.copilot/skills"
CLAUDE_RULES="${HOME}/.claude/rules"
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

# ─── Skills → ~/.copilot/skills ───
# Mirror Cursor skills to Copilot's user skills folder.
if [[ ! -d "$CURSOR_SKILLS" ]]; then
  echo "Note: No Cursor skills at $CURSOR_SKILLS (skipping Copilot skills)"
else
  COUNT=$(find "$CURSOR_SKILLS" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$COUNT" -eq 0 ]]; then
    echo "Note: No SKILL.md files found under $CURSOR_SKILLS"
  else
    echo "Syncing $COUNT Cursor skill(s) → $COPILOT_SKILLS..."
    run mkdir -p "$COPILOT_SKILLS"
    if command -v rsync &>/dev/null; then
      run rsync -a --delete "$CURSOR_SKILLS/" "$COPILOT_SKILLS/"
    else
      run rm -rf "$COPILOT_SKILLS"/*
      run cp -a "$CURSOR_SKILLS"/* "$COPILOT_SKILLS/" 2>/dev/null || true
    fi
    echo "  Mirrored to $COPILOT_SKILLS"
  fi
fi

# ─── Rules → ~/.copilot/skills/rules-sync-from-cursor and ~/.claude/rules ───
# Concatenate rules (*.mdc) for both Copilot skills and Claude/compatible editors.
if [[ ! -d "$RULES_DIR" ]]; then
  echo "Note: No rules dir at $RULES_DIR (skipping)"
else
  shopt -s nullglob
  MDC_FILES=("$RULES_DIR"/*.mdc)
  if [[ ${#MDC_FILES[@]} -eq 0 ]]; then
    echo "Note: No *.mdc files in $RULES_DIR"
  else
    content=""
    for f in $(printf '%s\n' "${MDC_FILES[@]}" | sort); do
      content+=$'\n\n'
      content+="$(cat "$f")"
    done
    merged="${content#[$'\n\n']}"

    echo "Syncing ${#MDC_FILES[@]} rule(s) → $COPILOT_SKILLS/rules-sync-from-cursor..."
    RULES_OUT="${COPILOT_SKILLS}/rules-sync-from-cursor"
    run mkdir -p "$RULES_OUT"
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] would write to $RULES_OUT/SKILL.md"
    else
      printf '%s' "$merged" > "${RULES_OUT}/SKILL.md"
      echo "  Wrote rules-sync-from-cursor/SKILL.md"
    fi

    echo "Syncing ${#MDC_FILES[@]} rule(s) → $CLAUDE_RULES..."
    run mkdir -p "$CLAUDE_RULES"
    if [[ "$DRY_RUN" == true ]]; then
      echo "[dry-run] would write to $CLAUDE_RULES/rules-sync-from-cursor.instructions.md"
    else
      {
        echo '---'
        echo 'name: Rules from Cursor (synced)'
        echo 'description: Global rules synced from Cursor'
        echo 'applyTo: "**"'
        echo '---'
        echo ''
        printf '%s' "$merged"
      } > "${CLAUDE_RULES}/rules-sync-from-cursor.instructions.md"
      echo "  Wrote rules-sync-from-cursor.instructions.md"
    fi
  fi
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
echo "Done. Restart VS Code to apply settings and Copilot skills."
echo "Note: Repo-level .github/copilot-instructions.md can be added per project."
