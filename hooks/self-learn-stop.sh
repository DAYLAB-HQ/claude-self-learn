#!/bin/bash
# self-learn-stop.sh — Session-end learning check reminder
#
# Runs on the Stop event. Its output is injected as additionalContext,
# prompting Claude to evaluate whether anything worth saving was learned
# during the session.

LEARNINGS_FILE="$HOME/.claude/self-improvement/LEARNINGS.jsonl"
MEMORY_DIR="$HOME/.claude/memory"

PATTERN_COUNT=$(ls "$MEMORY_DIR"/pattern_*.md 2>/dev/null | wc -l | tr -d ' ')
TROUBLESHOOT_COUNT=$(ls "$MEMORY_DIR"/troubleshoot_*.md 2>/dev/null | wc -l | tr -d ' ')
FEEDBACK_COUNT=$(ls "$MEMORY_DIR"/feedback_*.md 2>/dev/null | wc -l | tr -d ' ')
LEARNING_LINES=$(wc -l < "$LEARNINGS_FILE" 2>/dev/null | tr -d ' ')

cat <<EOF
[self-improvement] Session-end self-check:
1. Did I learn any new technical pattern this session?
2. Was there a repeated implementation pattern? (-> skill extraction candidate)
3. Did I discover anything wrong in existing memory?
4. Did I pick up any new technical preference from the user?

If anything is worth saving, propose it in one line. Otherwise stay silent.
Current state: pattern=${PATTERN_COUNT} troubleshoot=${TROUBLESHOOT_COUNT} feedback=${FEEDBACK_COUNT} learnings=${LEARNING_LINES:-0}
EOF
