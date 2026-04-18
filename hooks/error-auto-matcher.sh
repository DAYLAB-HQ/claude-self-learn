#!/bin/bash
# error-auto-matcher.sh — 빌드/런타임 에러 감지 시 기존 해법 자동 검색
#
# PostToolUse(Bash) 이벤트에서 실행.
# exit code ≠ 0이면 stderr에서 에러 키워드를 추출하고
# troubleshoot_*.md에서 매칭되는 해법을 찾아 Claude에게 주입.

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0' 2>/dev/null)
STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)
STDERR=$(echo "$INPUT" | jq -r '.tool_result.stderr // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# exit 0이면 무시 (detect-commit.sh가 처리)
[ "$EXIT_CODE" = "0" ] && exit 0
[ "$EXIT_CODE" = "null" ] && exit 0

MEMORY_DIR="$HOME/.claude/memory"
ERROR_TEXT="$STDERR $STDOUT"

# 에러 텍스트가 너무 짧으면 무시
[ ${#ERROR_TEXT} -lt 20 ] && exit 0

# 에러 키워드 추출 (흔한 에러 패턴)
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

# 키워드 없으면 종료
[ -z "$KEYWORDS" ] && exit 0

# troubleshoot 메모리에서 매칭 검색
MATCHES=""
MATCH_COUNT=0

for f in "$MEMORY_DIR"/troubleshoot_*.md; do
  [ -f "$f" ] || continue
  for kw in $KEYWORDS; do
    if grep -qil "$kw" "$f" 2>/dev/null; then
      fname=$(basename "$f" .md)
      desc=$(grep "^description:" "$f" 2>/dev/null | head -1 | sed 's/description: *//')
      # 중복 방지
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
[self-improvement] 에러 감지 — 기존 해법 ${MATCH_COUNT}개 매칭됨.
키워드: $KEYWORDS
매칭된 메모리:$(echo -e "$MATCHES")

위 메모리 파일을 읽고 이전 해결법을 먼저 시도하세요.
EOF
fi

exit 0
