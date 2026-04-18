#!/bin/bash
# calibration-tracker.sh — 빌드/명령 실패 시 도메인별 오답 기록
#
# PostToolUse(Bash) 이벤트에서 실행.
# exit code ≠ 0이면 실패한 도메인을 추정하고 calibration.json에 기록.
# 성공은 이 hook에서 자동 기록하지 않음 — /self-learn에서 수동 판단.
# (모든 성공 명령을 기록하면 노이즈가 너무 많음)

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
STDERR=$(echo "$INPUT" | jq -r '.tool_result.stderr // empty' 2>/dev/null)
STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)

# 성공이면 무시
[ "$EXIT_CODE" = "0" ] && exit 0
[ "$EXIT_CODE" = "null" ] && exit 0

# 에러 텍스트
ERROR_TEXT="$COMMAND $STDERR $STDOUT"
[ ${#ERROR_TEXT} -lt 20 ] && exit 0

CAL_FILE="$HOME/.claude/self-improvement/calibration.json"

# 도메인 추정
DOMAIN=""
echo "$ERROR_TEXT" | grep -qiE "next|nextjs|next build|next dev" && DOMAIN="nextjs"
echo "$ERROR_TEXT" | grep -qiE "nest|nestjs|@nestjs" && DOMAIN="nestjs"
echo "$ERROR_TEXT" | grep -qiE "expo|react-native|metro" && DOMAIN="expo"
echo "$ERROR_TEXT" | grep -qiE "prisma|@prisma" && DOMAIN="prisma"
echo "$ERROR_TEXT" | grep -qiE "tailwind|postcss" && DOMAIN="tailwind"
echo "$ERROR_TEXT" | grep -qiE "xcodebuild|CocoaPods|ios" && DOMAIN="ios_native"
echo "$ERROR_TEXT" | grep -qiE "gradle|android" && DOMAIN="android"
echo "$ERROR_TEXT" | grep -qiE "docker|Dockerfile" && DOMAIN="docker"
echo "$ERROR_TEXT" | grep -qiE "vercel|deploy" && DOMAIN="vercel"
echo "$ERROR_TEXT" | grep -qiE "typescript|tsc|\.ts" && DOMAIN="typescript"
echo "$ERROR_TEXT" | grep -qiE "pnpm|npm|yarn" && DOMAIN="package_manager"
echo "$ERROR_TEXT" | grep -qiE "git " && DOMAIN="git"

# 도메인 감지 못하면 무시
[ -z "$DOMAIN" ] && exit 0

# jq가 있으면 calibration.json 업데이트
if command -v jq &>/dev/null && [ -f "$CAL_FILE" ]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # 도메인이 없으면 초기화, 있으면 wrong +1
  UPDATED=$(jq --arg d "$DOMAIN" --arg ts "$TIMESTAMP" '
    .last_updated = $ts |
    .total_events += 1 |
    if .domains[$d] then
      .domains[$d].wrong += 1 |
      .domains[$d].accuracy = ((.domains[$d].correct / (.domains[$d].correct + .domains[$d].wrong)) * 100 | round / 100)
    else
      .domains[$d] = { "correct": 0, "wrong": 1, "accuracy": 0.0 }
    end
  ' "$CAL_FILE" 2>/dev/null)

  if [ -n "$UPDATED" ]; then
    echo "$UPDATED" > "$CAL_FILE"
  fi
fi

exit 0
