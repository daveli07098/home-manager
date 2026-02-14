#!/usr/bin/env bash
# Sync agents-skills from this repo to Cursor's global skills directory.
# Run from anywhere. Source is .cursor/skills next to this script's parent (agents-skills).
# Options: --prune  Remove skills from Cursor that are no longer in agents-skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SKILLS_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE="${AGENTS_SKILLS_ROOT}/.cursor/skills"
TARGET="${HOME}/.cursor/skills"
PRUNE=false

for arg in "$@"; do
  case "$arg" in
    --prune) PRUNE=true ;;
    -h|--help)
      echo "Usage: $0 [--prune]"
      echo "  Sync skills from agents-skills/.cursor/skills/ to ~/.cursor/skills/"
      echo "  --prune  Also remove skills in Cursor that are no longer in agents-skills"
      exit 0
      ;;
  esac
done

# ─── Validate source ───
if [[ ! -d "$SOURCE" ]]; then
  echo "Error: Source not found: $SOURCE"
  exit 1
fi

SKILL_COUNT=$(find "$SOURCE" -mindepth 1 -maxdepth 1 -type d | wc -l)
if [[ "$SKILL_COUNT" -eq 0 ]]; then
  echo "No skills found in $SOURCE"
  exit 0
fi

# ─── First-time setup ───
FIRST_RUN=false
if [[ ! -d "$TARGET" ]]; then
  FIRST_RUN=true
fi
mkdir -p "$TARGET"

if [[ "$FIRST_RUN" == true ]]; then
  echo "First run: creating $TARGET"
  echo ""
fi

# ─── Sync each skill ───
SYNCED=0
for skill_dir in "$SOURCE"/*; do
  if [[ -d "$skill_dir" ]]; then
    skill_name="$(basename "$skill_dir")"
    if [[ -d "$TARGET/$skill_name" ]]; then
      echo "→ Syncing  $skill_name"
    else
      echo "→ Adding   $skill_name"
    fi
    rsync -a --delete "$skill_dir/" "$TARGET/$skill_name/"
    ((SYNCED++)) || true
  fi
done

# ─── Optional: prune removed skills ───
if [[ "$PRUNE" == true ]]; then
  for target_skill in "$TARGET"/*; do
    if [[ -d "$target_skill" ]]; then
      name="$(basename "$target_skill")"
      if [[ ! -d "$SOURCE/$name" ]]; then
        echo "→ Removing $name (no longer in agents-skills)"
        rm -rf "$target_skill"
      fi
    fi
  done
fi

echo ""
echo "Done. $SYNCED skill(s) synced to $TARGET"
