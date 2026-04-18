#!/bin/bash
# session-start-preloader.sh — Preload relevant memory at session start (v4 lean)
#
# v4 (lean) changes vs v3.1:
#   - Removed MEMORY_INDEX.md generation (saved ~7k tokens per session)
#   - Claude uses Glob/Grep directly on ~/.claude/memory/*.md when needed
#   - Preloader still shows top-N relevant for the current project
#   - rules/memory-first.md instructs Claude's workflow
#
# Output sections:
#   1. Project + detected stacks
#   2. Top-N relevant memories (stack-scored)
#   3. Memory-first hint (short)
#   4. NEXT_SESSION.md handoff + recent learnings + calibration
#
# Config (env vars):
#   SELF_LEARN_TOP_N     Max top memories to list in preload (default: 10)
#   SELF_LEARN_FULL_INDEX Set to 1 to also emit full memory index (heavy, ~7k tokens)

MEMORY_DIR="$HOME/.claude/memory"
SELF_IMPROVE_DIR="$HOME/.claude/self-improvement"
INDEX_FILE="$SELF_IMPROVE_DIR/memory_index.json"
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
TOP_N="${SELF_LEARN_TOP_N:-10}"

# =============================================================================
# 1. Detect project stacks
# =============================================================================
STACKS=""
[ -f "$CWD/package.json" ] && {
  grep -q "next" "$CWD/package.json" 2>/dev/null && STACKS="$STACKS nextjs"
  grep -q "nestjs" "$CWD/package.json" 2>/dev/null && STACKS="$STACKS nestjs"
  grep -q "expo" "$CWD/package.json" 2>/dev/null && STACKS="$STACKS expo"
  grep -q "prisma" "$CWD/package.json" 2>/dev/null && STACKS="$STACKS prisma"
  grep -q "react-native" "$CWD/package.json" 2>/dev/null && STACKS="$STACKS react-native"
}
for pkg in "$CWD"/apps/*/package.json "$CWD"/packages/*/package.json; do
  [ -f "$pkg" ] || continue
  grep -q "next" "$pkg" 2>/dev/null && STACKS="$STACKS nextjs"
  grep -q "nestjs" "$pkg" 2>/dev/null && STACKS="$STACKS nestjs"
  grep -q "expo" "$pkg" 2>/dev/null && STACKS="$STACKS expo"
  grep -q "prisma" "$pkg" 2>/dev/null && STACKS="$STACKS prisma"
  grep -q "react-native" "$pkg" 2>/dev/null && STACKS="$STACKS react-native"
done
STACKS=$(echo "$STACKS" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

# =============================================================================
# 2. Top-N relevant (stack-scored)
# =============================================================================
CANDIDATES=""
SOURCE="grep"

if [ -f "$INDEX_FILE" ] && command -v jq &>/dev/null && [ -n "$STACKS" ]; then
  SOURCE="index"
  NOW=$(date -u +%s)
  STACK_LIST=$(echo "$STACKS" | tr ' ' ',' | sed 's/^,//;s/,$//')

  CANDIDATES=$(jq -r --arg stacks "$STACK_LIST" --arg project "$PROJECT_NAME" --argjson now "$NOW" '
    ($stacks | split(",")) as $stack_arr |
    .files | to_entries[] |
    (.value.keywords // []) as $kws |
    ([$kws[] | select(. as $k | $stack_arr | any(. == $k))] | length) as $keyword_score |
    (if .value.last_accessed then
      (($now - ((.value.last_accessed | fromdateiso8601? // 0))) / 86400) as $days |
      (if $days < 7 then 5
       elif $days < 30 then 2
       elif $days > 90 then -5
       else 0 end)
    else 0 end) as $recency |
    (if (.value.projects // []) | any(. == $project) then 5 else 0 end) as $project_bonus |
    (if .value.hit_count then ([.value.hit_count, 5] | min) else 0 end) as $hit_bonus |
    ($keyword_score * 3 + $recency + $project_bonus + $hit_bonus) as $score |
    select($keyword_score > 0 or $project_bonus > 0) |
    "\($score)|\(.key)|\(.value.type // "unknown")|\(.value.description // "")"
  ' "$INDEX_FILE" 2>/dev/null)
fi

if [ -z "$CANDIDATES" ] && [ -n "$STACKS" ]; then
  SOURCE="grep"
  SEEN=""
  for stack in $STACKS; do
    for f in "$MEMORY_DIR"/pattern_*.md "$MEMORY_DIR"/troubleshoot_*.md "$MEMORY_DIR"/reference_*.md; do
      [ -f "$f" ] || continue
      fname=$(basename "$f")
      case " $SEEN " in *" $fname "*) continue ;; esac
      if grep -qil "$stack" "$f" 2>/dev/null; then
        SEEN="$SEEN $fname"
        desc=$(grep "^description:" "$f" 2>/dev/null | head -1 | sed 's/description: *//;s/^ *//;s/ *$//')
        type=$(echo "$fname" | sed -E 's/^([^_]+)_.*/\1/')
        mtime=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null)
        age_days=$(( ( $(date +%s) - mtime ) / 86400 ))
        if [ "$age_days" -lt 7 ]; then recency=5
        elif [ "$age_days" -lt 30 ]; then recency=2
        elif [ "$age_days" -gt 90 ]; then recency=-5
        else recency=0
        fi
        score=$((3 + recency))
        CANDIDATES="$CANDIDATES
$score|$fname|$type|$desc"
      fi
    done
  done
fi

if [ -n "$CANDIDATES" ]; then
  TOP=$(printf '%s\n' "$CANDIDATES" | awk 'NF' | sort -t'|' -k1 -rn | head -n "$TOP_N")
  TOTAL_RELEVANT=$(printf '%s\n' "$CANDIDATES" | awk 'NF' | wc -l | tr -d ' ')
  SHOWN_COUNT=$(printf '%s\n' "$TOP" | awk 'NF' | wc -l | tr -d ' ')
else
  TOP=""
  TOTAL_RELEVANT=0
  SHOWN_COUNT=0
fi

PATTERNS=""
TROUBLESHOOTS=""
REFERENCES=""
PATTERN_CNT=0
TROUBLE_CNT=0
REFERENCE_CNT=0

while IFS='|' read -r score file type desc; do
  [ -z "$file" ] && continue
  line="  - ${file%.md}: $desc"
  case "$type" in
    pattern)      PATTERNS="$PATTERNS"$'\n'"$line"      ; PATTERN_CNT=$((PATTERN_CNT+1)) ;;
    troubleshoot) TROUBLESHOOTS="$TROUBLESHOOTS"$'\n'"$line" ; TROUBLE_CNT=$((TROUBLE_CNT+1)) ;;
    reference)    REFERENCES="$REFERENCES"$'\n'"$line"  ; REFERENCE_CNT=$((REFERENCE_CNT+1)) ;;
  esac
done <<< "$TOP"

# =============================================================================
# 3. Count total memories (for hint message)
# =============================================================================
TOTAL_FILES=0
if [ -f "$INDEX_FILE" ] && command -v jq &>/dev/null; then
  TOTAL_FILES=$(jq '.files | length' "$INDEX_FILE" 2>/dev/null)
fi
[ "$TOTAL_FILES" -eq 0 ] && TOTAL_FILES=$(ls "$MEMORY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

# =============================================================================
# 4. Optional: full MEMORY_INDEX.md (opt-in only)
# =============================================================================
INDEX_MD_PATH=""
if [ "${SELF_LEARN_FULL_INDEX:-0}" = "1" ] && [ -f "$INDEX_FILE" ] && command -v jq &>/dev/null; then
  INDEX_MD="$SELF_IMPROVE_DIR/MEMORY_INDEX.md"
  jq -r '
    [.files | to_entries[]] |
    group_by(.value.type // "other") |
    sort_by(
      (.[0].value.type // "other") as $t |
      ({"pattern":1,"troubleshoot":2,"feedback":3,"reference":4} | (.[$t] // 99))
    ) |
    map(
      (.[0].value.type // "other") as $type |
      (. | length) as $count |
      (. | sort_by(.value.last_accessed // "") | reverse) as $sorted |
      "## \($type) (\($count))\n\n" +
      ($sorted | map("- **\(.key | sub("\\.md$"; ""))** — \(.value.description // "(no description)")") | join("\n"))
    ) |
    join("\n\n---\n\n")
  ' "$INDEX_FILE" 2>/dev/null > "$INDEX_MD.tmp"
  if [ -s "$INDEX_MD.tmp" ]; then
    {
      echo "# Memory Index"
      echo ""
      echo "Auto-generated. Source: \`$INDEX_FILE\`"
      echo ""
      cat "$INDEX_MD.tmp"
    } > "$INDEX_MD"
    INDEX_MD_PATH="$INDEX_MD"
  fi
  rm -f "$INDEX_MD.tmp"
fi

# =============================================================================
# 5. NEXT_SESSION.md handoff + recent learnings + calibration
# =============================================================================
NEXT_SESSION=""
[ -f "$CWD/.claude/NEXT_SESSION.md" ] && NEXT_SESSION=$(cat "$CWD/.claude/NEXT_SESSION.md")

RECENT_LEARNINGS=""
if [ -f "$SELF_IMPROVE_DIR/LEARNINGS.jsonl" ]; then
  RECENT_COUNT=$(grep -c "$PROJECT_NAME" "$SELF_IMPROVE_DIR/LEARNINGS.jsonl" 2>/dev/null | head -1 | tr -d '[:space:]')
  RECENT_COUNT=${RECENT_COUNT:-0}
  [ "$RECENT_COUNT" -gt 0 ] 2>/dev/null && RECENT_LEARNINGS="Learning history for this project: ${RECENT_COUNT} events"
fi

CAL_FILE="$SELF_IMPROVE_DIR/calibration.json"
CAL_WARNINGS=""
if [ -f "$CAL_FILE" ] && command -v jq &>/dev/null; then
  LOW_DOMAINS=$(jq -r '.domains | to_entries[] | select((.value.correct + .value.wrong) >= 5 and .value.accuracy < 0.5) | "\(.key) (\(.value.accuracy * 100 | round)%)"' "$CAL_FILE" 2>/dev/null)
  [ -n "$LOW_DOMAINS" ] && CAL_WARNINGS="Low-confidence domains (<50%): $LOW_DOMAINS — WebSearch first!"
fi

# =============================================================================
# 6. Emit
# =============================================================================
HAS_OUTPUT=false
OUTPUT="[self-improvement] Session preload
Project: $PROJECT_NAME"

if [ -n "$STACKS" ]; then
  OUTPUT="$OUTPUT
Detected stacks: $STACKS"
  HAS_OUTPUT=true
fi

if [ "$SHOWN_COUNT" -gt 0 ]; then
  MORE_HINT=""
  [ "$TOTAL_RELEVANT" -gt "$SHOWN_COUNT" ] && MORE_HINT=" (top $SHOWN_COUNT of $TOTAL_RELEVANT stack-relevant)"

  OUTPUT="$OUTPUT

Relevant memories for this project$MORE_HINT:"
  [ "$PATTERN_CNT" -gt 0 ] && OUTPUT="$OUTPUT
patterns ($PATTERN_CNT):$PATTERNS"
  [ "$TROUBLE_CNT" -gt 0 ] && OUTPUT="$OUTPUT
troubleshoots ($TROUBLE_CNT):$TROUBLESHOOTS"
  [ "$REFERENCE_CNT" -gt 0 ] && OUTPUT="$OUTPUT
references ($REFERENCE_CNT):$REFERENCES"
  HAS_OUTPUT=true
fi

# Compact memory-first hint (no heavy index)
if [ "$TOTAL_FILES" -gt 0 ]; then
  if [ -n "$INDEX_MD_PATH" ]; then
    OUTPUT="$OUTPUT

📚 $TOTAL_FILES memory files at ~/.claude/memory/*.md (full index: $INDEX_MD_PATH).
   See ~/.claude/rules/memory-first.md for the memory-first workflow."
  else
    OUTPUT="$OUTPUT

📚 $TOTAL_FILES memory files at ~/.claude/memory/*.md.
   Use Glob + Read to find relevant memories. Workflow: ~/.claude/rules/memory-first.md"
  fi
  HAS_OUTPUT=true
fi

if [ -n "$NEXT_SESSION" ]; then
  OUTPUT="$OUTPUT

Previous session handoff:
$NEXT_SESSION"
  HAS_OUTPUT=true
fi

[ -n "$RECENT_LEARNINGS" ] && OUTPUT="$OUTPUT
$RECENT_LEARNINGS" && HAS_OUTPUT=true
[ -n "$CAL_WARNINGS" ] && OUTPUT="$OUTPUT
⚠️ $CAL_WARNINGS" && HAS_OUTPUT=true

if [ "$HAS_OUTPUT" = true ] && [ "$SOURCE" = "index" ]; then
  OUTPUT="$OUTPUT

(indexed lookup)"
fi

[ "$HAS_OUTPUT" = true ] && echo "$OUTPUT"

exit 0
