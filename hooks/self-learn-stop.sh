#!/bin/bash
# self-learn-stop.sh — 세션 종료 시 학습 체크 리마인더
#
# Stop 이벤트에서 실행. Claude의 additionalContext로 주입되어
# 세션에서 배운 기술 패턴을 저장할지 자기 점검하게 한다.

LEARNINGS_FILE="$HOME/.claude/self-improvement/LEARNINGS.jsonl"
MEMORY_DIR="$HOME/.claude/memory"

# 현재 메모리 현황
PATTERN_COUNT=$(ls "$MEMORY_DIR"/pattern_*.md 2>/dev/null | wc -l | tr -d ' ')
TROUBLESHOOT_COUNT=$(ls "$MEMORY_DIR"/troubleshoot_*.md 2>/dev/null | wc -l | tr -d ' ')
FEEDBACK_COUNT=$(ls "$MEMORY_DIR"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')
LEARNING_LINES=$(wc -l < "$LEARNINGS_FILE" 2>/dev/null | tr -d ' ')

cat <<EOF
[self-improvement] 세션 종료 전 자기 점검:
1. 이번 세션에서 새로 배운 기술적 패턴이 있는가?
2. 반복된 구현 패턴이 있었는가? (→ 스킬 추출 후보)
3. 기존 메모리 중 틀린 것을 발견했는가?
4. 유저의 새로운 기술적 선호를 감지했는가?

저장할 게 있으면 한 줄로 제안. 없으면 무시.
현황: pattern=${PATTERN_COUNT} troubleshoot=${TROUBLESHOOT_COUNT} feedback=${FEEDBACK_COUNT} learnings=${LEARNING_LINES:-0}
EOF
