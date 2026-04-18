#!/bin/bash
# error-auto-matcher.sh — Match build/runtime errors against previous troubleshoot memories
#
# Runs on PostToolUse(Bash). When a command exits with a non-zero code,
# extracts error keywords from stderr/stdout and searches troubleshoot_*.md
# files for matching prior solutions. If any are found, surfaces them to Claude.

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0' 2>/dev/null)
STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)
STDERR=$(echo "$INPUT" | jq -r '.tool_result.stderr // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Ignore successful commands (detect-commit.sh handles those)
[ "$EXIT_CODE" = "0" ] && exit 0
[ "$EXIT_CODE" = "null" ] && exit 0

MEMORY_DIR="$HOME/.claude/memory"
ERROR_TEXT="$STDERR $STDOUT"

# Skip if the error text is too short to be meaningful
[ ${#ERROR_TEXT} -lt 20 ] && exit 0

# Extract error keywords (common patterns)
KEYWORDS=""

# TypeScript/JavaScript
echo "$ERROR_TEXT" | grep -qiE "cannot find module|module not found" && KEYWORDS="$KEYWORDS module_not_found"
echo "$ERROR_TEXT" | grep -qiE "type error|TypeError" && KEYWORDS="$KEYWORDS type_error"
echo "$ERROR_TEXT" | grep -qiE "syntax error|SyntaxError" && KEYWORDS="$KEYWORDS syntax_error"
echo "$ERROR_TEXT" | grep -qiE "ENOENT|no such file" && KEYWORDS="$KEYWORDS file_not_found"
echo "$ERROR_TEXT" | grep -qiE "EADDRINUSE|address already in use" && KEYWORDS="$KEYWORDS port_conflict"
echo "$ERROR_TEXT" | grep -qiE "peer dep|peerDependencies" && KEYWORDS="$KEYWORDS peer_dependency"
echo "$ERROR_TEXT" | grep -qiE "out of memory|heap|ENOMEM" && KEYWORDS="$KEYWORDS memory"

# Build tools
echo "$ERROR_TEXT" | grep -qiE "next build|next dev" && KEYWORDS="$KEYWORDS nextjs"
echo "$ERROR_TEXT" | grep -qiE "expo|react-native" && KEYWORDS="$KEYWORDS expo react-native"
echo "$ERROR_TEXT" | grep -qiE "prisma" && KEYWORDS="$KEYWORDS prisma"
echo "$ERROR_TEXT" | grep -qiE "nest|nestjs" && KEYWORDS="$KEYWORDS nestjs"
echo "$ERROR_TEXT" | grep -qiE "turbo|turborepo" && KEYWORDS="$KEYWORDS turbo"

# iOS/Android
echo "$ERROR_TEXT" | grep -qiE "xcodebuild|pod install|CocoaPods" && KEYWORDS="$KEYWORDS ios xcode"
echo "$ERROR_TEXT" | grep -qiE "gradle|android" && KEYWORDS="$KEYWORDS android"

# Nothing matched? Skip silently.
[ -z "$KEYWORDS" ] && exit 0

# Search troubleshoot memories for matching keywords
MATCHES=""
MATCH_COUNT=0

for f in "$MEMORY_DIR"/troubleshoot_*.md; do
  [ -f "$f" ] || continue
  for kw in $KEYWORDS; do
    if grep -qil "$kw" "$f" 2>/dev/null; then
      fname=$(basename "$f" .md)
      desc=$(grep "^description:" "$f" 2>/dev/null | head -1 | sed 's/description: *//')
      # Dedup
      echo "$MATCHES" | grep -q "$fname" || {
        MATCHES="$MATCHES\n  - $fname: $desc"
        MATCH_COUNT=$((MATCH_COUNT + 1))
      }
      break
    fi
  done
done

if [ $MATCH_COUNT -gt 0 ]; then
  cat <<EOF
[self-improvement] Error detected — ${MATCH_COUNT} prior solution(s) match.
Keywords: $KEYWORDS
Matched memories:$(echo -e "$MATCHES")

Read the memory files above and try the previous solution(s) first.
EOF
fi

exit 0
