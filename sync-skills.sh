#!/usr/bin/env bash
#
# sync-skills.sh — push skills from THIS repo (the source of truth) to the
# local Claude Code and Gemini installs.
#
# Usage:
#   ./sync-skills.sh             sync every skill in the repo
#   ./sync-skills.sh NAME...     sync only the named skill(s)
#   ./sync-skills.sh --check     report drift only, write nothing (exit 1 if drift)
#   ./sync-skills.sh -h          show this help
#
# Per skill it:
#   1. rebuilds the repo's <name>.skill ZIP from SKILL.md (only if stale),
#   2. copies SKILL.md       -> ~/.claude/skills/<name>/SKILL.md
#   3. copies SKILL.md       -> ~/.gemini/.../skills/<name>/SKILL.md
#      and the rebuilt ZIP   -> ~/.gemini/.../skills/<name>/<name>.skill
#
# A skill is treated as "packaged" iff the repo holds its <name>.skill.
# Claude reads SKILL.md directly, so no ZIP is written there.
# Gemini wrappers (gemini-extension.json, plugin.json) are never touched.
# Skills present in a target but absent from the repo (e.g. graphify) are left alone.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude/skills"
GEMINI_DIR="$HOME/.gemini/config/plugins/custom/skills"

CHECK=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --check)   CHECK=1 ;;
    -h|--help) sed -n '2,29p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        echo "unknown flag: $a" >&2; exit 2 ;;
    *)         ARGS+=("$a") ;;
  esac
done

drift=0

# Resolve the skill list: explicit args, else every repo dir with a SKILL.md.
skills=()
if [ "${#ARGS[@]}" -gt 0 ]; then
  skills=("${ARGS[@]}")
else
  for d in "$REPO"/*/ ; do
    name="$(basename "$d")"
    [ "$name" = "legacy" ] && continue
    [ -f "$d/SKILL.md" ] && skills+=("$name")
  done
fi
if [ "${#skills[@]}" -eq 0 ]; then echo "no skills found"; exit 0; fi

# copy $1 -> $2 only when they differ; honors --check. Labelled by $3.
sync_file() {
  local src="$1" dst="$2" label="$3"
  [ -f "$src" ] || return 0
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then return 0; fi
  drift=1
  if [ "$CHECK" -eq 1 ]; then
    echo "  DRIFT  $label"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  sync   $label"
  fi
}

# 0 if the repo's <name>.skill already contains the current SKILL.md.
zip_matches() {
  local sdir="$1" name="$2" zip tmp rc
  zip="$sdir/$name.skill"
  [ -f "$zip" ] || return 1
  tmp="$(mktemp)"
  if unzip -p "$zip" "$name/SKILL.md" > "$tmp" 2>/dev/null && cmp -s "$tmp" "$sdir/SKILL.md"; then
    rc=0
  else
    rc=1
  fi
  rm -f "$tmp"
  return $rc
}

for name in "${skills[@]}"; do
  sdir="$REPO/$name"
  smd="$sdir/SKILL.md"
  if [ ! -f "$smd" ]; then echo "$name: no SKILL.md in repo — skipped"; continue; fi
  echo "$name:"

  # 1) Repackage the repo ZIP from SKILL.md when stale (packaged skills only).
  if [ -f "$sdir/$name.skill" ] && ! zip_matches "$sdir" "$name"; then
    drift=1
    if [ "$CHECK" -eq 1 ]; then
      echo "  DRIFT  repo $name.skill (stale package)"
    else
      ( cd "$REPO" && rm -f "$name/$name.skill" && zip -X -q "$name/$name.skill" "$name/SKILL.md" )
      echo "  build  repo $name.skill"
    fi
  fi

  # 2) Claude install — SKILL.md only.
  sync_file "$smd" "$CLAUDE_DIR/$name/SKILL.md" ".claude/$name/SKILL.md"

  # 3) Gemini install — SKILL.md (+ ZIP for packaged skills), if the plugin dir exists.
  if [ -d "$GEMINI_DIR/$name" ]; then
    sync_file "$smd" "$GEMINI_DIR/$name/SKILL.md" ".gemini/$name/SKILL.md"
    [ -f "$sdir/$name.skill" ] && \
      sync_file "$sdir/$name.skill" "$GEMINI_DIR/$name/$name.skill" ".gemini/$name/$name.skill"
  else
    echo "  skip   .gemini/$name (no plugin dir — add wrappers first)"
  fi
done

echo
if [ "$CHECK" -eq 1 ]; then
  [ "$drift" -eq 1 ] && { echo "drift detected"; exit 1; } || echo "all in sync"
else
  echo "done"
fi
