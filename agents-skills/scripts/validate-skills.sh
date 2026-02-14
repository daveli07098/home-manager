#!/usr/bin/env bash
# Validate SKILL.md files (frontmatter: name, description, name matches folder).
# Run from anywhere. By default validates agents-skills/.cursor/skills.
# Options: --user  Also validate ~/.cursor/skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SKILLS_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DEFAULT="${AGENTS_SKILLS_ROOT}/.cursor/skills"
TARGET_USER="${HOME}/.cursor/skills"
VALIDATE_USER=false

for arg in "$@"; do
  case "$arg" in
    --user) VALIDATE_USER=true ;;
    -h|--help)
      echo "Usage: $0 [--user]"
      echo "  Validate SKILL.md frontmatter (name, description, name = folder name)."
      echo "  Default: validate ${SOURCE_DEFAULT}"
      echo "  --user  Also validate ${TARGET_USER}"
      exit 0
      ;;
  esac
done

validate_one() {
  local f="$1"
  local dir dir_parent block name desc ok_name ok_desc ok_match
  dir="$(dirname "$f")"
  dir_parent="$(basename "$dir")"
  block="$(sed -n '/^---$/,/^---$/p' "$f" 2>/dev/null | head -30)"
  name="$(echo "$block" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '\r')"
  desc="$(echo "$block" | sed -n 's/^description:[[:space:]]*//p' | head -1 | tr -d '\r')"
  echo "$name" | grep -qE '^[a-z0-9-]+$' && ok_name=1 || ok_name=0
  [[ -n "$desc" ]] && ok_desc=1 || ok_desc=0
  [[ "$name" == "$dir_parent" ]] && ok_match=1 || ok_match=0
  if [[ $ok_name -eq 1 && $ok_desc -eq 1 && $ok_match -eq 1 ]]; then
    echo "OK   $f"
    return 0
  else
    echo "FAIL $f (name='$name' parent='$dir_parent' name_ok=$ok_name desc_ok=$ok_desc match=$ok_match)"
    return 1
  fi
}

FAIL=0
OK=0

if [[ -d "$SOURCE_DEFAULT" ]]; then
  echo "=== $SOURCE_DEFAULT ==="
  while IFS= read -r -d '' f; do
    if validate_one "$f"; then ((OK++)) || true; else ((FAIL++)) || true; fi
  done < <(find "$SOURCE_DEFAULT" -name SKILL.md -print0 2>/dev/null)
  echo ""
fi

if [[ "$VALIDATE_USER" == true && -d "$TARGET_USER" ]]; then
  echo "=== $TARGET_USER ==="
  while IFS= read -r -d '' f; do
    if validate_one "$f"; then ((OK++)) || true; else ((FAIL++)) || true; fi
  done < <(find "$TARGET_USER" -name SKILL.md -print0 2>/dev/null)
  echo ""
fi

TOTAL=$((OK + FAIL))
echo "Summary: total=$TOTAL success=$OK fail=$FAIL"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
echo "All skills valid."
exit 0
