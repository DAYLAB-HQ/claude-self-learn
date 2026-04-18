#!/bin/bash
# calibration-tracker.sh — Track per-domain wrong counts on build/command failure
#
# Runs on PostToolUse(Bash). When a command exits with a non-zero code,
# infers the domain from the command/stderr and increments `wrong` in
# calibration.json. Successful commands are NOT auto-recorded here —
# `/self-learn` makes that call manually (recording every success would be
# too noisy).

INPUT=$(cat)
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result.exit_code // 0' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
STDERR=$(echo "$INPUT" | jq -r '.tool_result.stderr // empty' 2>/dev/null)
STDOUT=$(echo "$INPUT" | jq -r '.tool_result.stdout // empty' 2>/dev/null)

# Skip successful commands
[ "$EXIT_CODE" = "0" ] && exit 0
[ "$EXIT_CODE" = "null" ] && exit 0

ERROR_TEXT="$COMMAND $STDERR $STDOUT"
[ ${#ERROR_TEXT} -lt 20 ] && exit 0

CAL_FILE="$HOME/.claude/self-improvement/calibration.json"

# Infer the domain from the error text
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

# Skip if no domain could be inferred
[ -z "$DOMAIN" ] && exit 0

# Update calibration.json if jq is available
if command -v jq &>/dev/null && [ -f "$CAL_FILE" ]; then
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Initialize domain if missing, otherwise increment wrong
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
