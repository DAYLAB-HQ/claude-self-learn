#!/bin/bash
# uninstall.sh — self-learn uninstaller
#
# Usage: ./uninstall.sh
#
# By default, this only removes installed code files.
# Accumulated data in ~/.claude/memory/ and ~/.claude/self-improvement/ is preserved.
# To remove data as well, use --purge.

set -e

CLAUDE_DIR="$HOME/.claude"
PURGE=0

for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=1 ;;
    --help|-h)
      cat <<EOF
self-learn uninstaller

Usage:
  ./uninstall.sh           Remove hooks, skills, commands, rules only (data preserved)
  ./uninstall.sh --purge   Remove accumulated memory and learning logs too (IRREVERSIBLE!)
EOF
      exit 0
      ;;
  esac
done

echo "🗑  Uninstalling self-learn..."

# Hooks
for f in session-start-preloader.sh self-learn-stop.sh detect-commit.sh error-auto-matcher.sh calibration-tracker.sh; do
  [ -f "$CLAUDE_DIR/hooks/$f" ] && rm "$CLAUDE_DIR/hooks/$f" && echo "  - hooks/$f"
done

# Skill
if [ -d "$CLAUDE_DIR/skills/self-learn" ]; then
  rm -rf "$CLAUDE_DIR/skills/self-learn"
  echo "  - skills/self-learn/"
fi

# Commands
if [ -d "$CLAUDE_DIR/commands/self-learn" ]; then
  rm -rf "$CLAUDE_DIR/commands/self-learn"
  echo "  - commands/self-learn/"
fi

# Rules (all rules this package installs)
for f in self-improvement.md memory-first.md; do
  [ -f "$CLAUDE_DIR/rules/$f" ] && rm "$CLAUDE_DIR/rules/$f" && echo "  - rules/$f"
done

if [ "$PURGE" -eq 1 ]; then
  echo ""
  echo "⚠️  --purge mode: will remove accumulated data"
  read -p "Really delete data in ~/.claude/self-improvement/ and memory/? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CLAUDE_DIR/self-improvement"
    echo "  - self-improvement/ (entire directory)"
    rm -rf "$CLAUDE_DIR/memory"
    echo "  - memory/ (entire directory)"
  else
    echo "  Data preserved (cancelled)"
  fi
fi

echo ""
echo "✅ Uninstall complete"
echo ""
echo "🚨 Last step: manually remove the hooks section from ~/.claude/settings.json"
echo "   (session-start-preloader, self-learn-stop, detect-commit, error-auto-matcher, calibration-tracker)"
