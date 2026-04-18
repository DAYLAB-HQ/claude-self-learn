#!/bin/bash
# detect-commit.sh — git commit 감지 후 학습 로그 기록
#
# PostToolUse(Bash) 이벤트에서 실행.
# git commit 명령이 감지되면 LEARNINGS.jsonl에 커밋 이벤트를 기록하고
# Claude에게 학습 체크를 유도한다.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# git commit 명령인지 체크
if echo "$COMMAND" | grep -qE 'git commit'; then
  LEARNINGS_FILE="$HOME/.claude/self-improvement/LEARNINGS.jsonl"
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  PROJECT=$(basename "$(pwd)")

  # LEARNINGS.jsonl에 커밋 이벤트 기록
  echo "{\"ts\":\"$TIMESTAMP\",\"project\":\"$PROJECT\",\"category\":\"commit\",\"title\":\"git commit detected\",\"verified\":false}" >> "$LEARNINGS_FILE"

  echo "[self-improvement] 커밋 감지. 이 커밋에서 기술적으로 배운 패턴이 있다면 세션 종료 시 /self-learn으로 저장 가능."
fi

exit 0
