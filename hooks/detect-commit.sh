#!/bin/bash
# detect-commit.sh — Log git commit events to LEARNINGS.jsonl
#
# Runs on PostToolUse(Bash). When a `git commit` command is detected,
# records the event in LEARNINGS.jsonl and prompts Claude to check for
# anything worth saving from the work leading up to the commit.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if echo "$COMMAND" | grep -qE 'git commit'; then
  LEARNINGS_FILE="$HOME/.claude/self-improvement/LEARNINGS.jsonl"
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  PROJECT=$(basename "$(pwd)")

  echo "{\"ts\":\"$TIMESTAMP\",\"project\":\"$PROJECT\",\"category\":\"commit\",\"title\":\"git commit detected\",\"verified\":false}" >> "$LEARNINGS_FILE"

  echo "[self-improvement] Commit detected. If this commit contains a reusable technical pattern, consider running /self-learn at the end of the session."
fi

exit 0
