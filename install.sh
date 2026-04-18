#!/bin/bash
# install.sh — self-learn installer
#
# Safety principles:
#   1. Pre-flight scan → show conflicts → confirm before execution
#   2. Existing code files are skipped by default (--backup or --force to override)
#   3. Data files (memory, learning logs, calibration, audit) are NEVER overwritten
#   4. settings.json is merged safely (backup + duplicate detection)

set -e

CLAUDE_DIR="$HOME/.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for friendlier output (disable if not a TTY)
if [ -t 1 ]; then
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_RESET=$'\033[0m'
else
  C_BOLD=''; C_DIM=''; C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_RESET=''
fi

# Flags
DRY_RUN=0
FORCE=0
BACKUP=0
YES=0
NO_MERGE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --force|-f) FORCE=1 ;;
    --backup|-b) BACKUP=1 ;;
    --yes|-y) YES=1 ;;
    --no-merge-settings) NO_MERGE=1 ;;
    --help|-h)
      cat <<'EOF'
self-learn installer

Usage:
  ./install.sh              Interactive install (recommended) — prompts for confirmation
  ./install.sh --yes        Automatic install — no confirmation, safe defaults
  ./install.sh --backup     Back up existing code files as .bak, then overwrite
  ./install.sh --force      Overwrite existing code files (no backup)
  ./install.sh --dry-run    Print the plan without making changes

Other options:
  --no-merge-settings       Skip auto-merging settings.json (manual merge required)

❗ Safety guarantees — the following are NEVER touched, even with --force:
  - ~/.claude/memory/ contents     (all your existing memories stay)
  - ~/.claude/self-improvement/    existing files (learning + audit logs stay)

settings.json is backed up (.bak) and only the hooks section is merged.
EOF
      exit 0
      ;;
  esac
done

echo ""
echo "${C_BOLD}${C_BLUE}┌─────────────────────────────────────────────┐${C_RESET}"
echo "${C_BOLD}${C_BLUE}│  self-learn installer                       │${C_RESET}"
echo "${C_BOLD}${C_BLUE}└─────────────────────────────────────────────┘${C_RESET}"
echo ""

# =============================================================================
# Prerequisites
# =============================================================================
echo "${C_BOLD}1. Prerequisites${C_RESET}"
MISSING=0

if ! command -v jq &>/dev/null; then
  echo "   ${C_RED}✗${C_RESET} jq not found"
  echo "     ${C_DIM}Install:${C_RESET}"
  echo "     ${C_DIM}  macOS:  brew install jq${C_RESET}"
  echo "     ${C_DIM}  Linux:  sudo apt install jq${C_RESET}"
  MISSING=1
else
  echo "   ${C_GREEN}✓${C_RESET} jq"
fi

if [ ! -d "$CLAUDE_DIR" ]; then
  echo "   ${C_YELLOW}!${C_RESET} ~/.claude/ not found — will be created"
else
  echo "   ${C_GREEN}✓${C_RESET} ~/.claude/ exists"
fi

if [ $MISSING -eq 1 ]; then
  echo ""
  echo "${C_RED}Please install the missing packages above, then re-run.${C_RESET}"
  exit 1
fi

# =============================================================================
# Plan (pre-flight scan)
# =============================================================================

declare -a code_files
declare -a data_files

for hook in "$SCRIPT_DIR"/hooks/*.sh; do
  code_files+=("$hook|$CLAUDE_DIR/hooks/$(basename "$hook")")
done
for f in "$SCRIPT_DIR"/skills/self-learn/*.md; do
  code_files+=("$f|$CLAUDE_DIR/skills/self-learn/$(basename "$f")")
done
for f in "$SCRIPT_DIR"/commands/self-learn/*.md; do
  code_files+=("$f|$CLAUDE_DIR/commands/self-learn/$(basename "$f")")
done
for f in "$SCRIPT_DIR"/rules/*.md; do
  [ -f "$f" ] || continue
  code_files+=("$f|$CLAUDE_DIR/rules/$(basename "$f")")
done

data_files+=("$SCRIPT_DIR/templates/LEARNINGS.jsonl|$CLAUDE_DIR/self-improvement/LEARNINGS.jsonl")
data_files+=("$SCRIPT_DIR/templates/SKILLS_TRACKER.json|$CLAUDE_DIR/self-improvement/SKILLS_TRACKER.json")
data_files+=("$SCRIPT_DIR/templates/calibration.json|$CLAUDE_DIR/self-improvement/calibration.json")
data_files+=("$SCRIPT_DIR/templates/AUDIT_LOG.md|$CLAUDE_DIR/self-improvement/AUDIT_LOG.md")
data_files+=("$SCRIPT_DIR/templates/MEMORY.md|$CLAUDE_DIR/memory/MEMORY.md")

declare -a new_code conflict_code new_data existing_data
for entry in "${code_files[@]}"; do
  src="${entry%%|*}"; dst="${entry##*|}"
  [ -f "$dst" ] && conflict_code+=("$dst") || new_code+=("$dst")
done
for entry in "${data_files[@]}"; do
  src="${entry%%|*}"; dst="${entry##*|}"
  [ -f "$dst" ] && existing_data+=("$dst") || new_data+=("$dst")
done

# =============================================================================
# Report
# =============================================================================
echo ""
echo "${C_BOLD}2. Preview of changes${C_RESET}"

if [ ${#new_code[@]} -gt 0 ]; then
  echo ""
  echo "   ${C_GREEN}New files to install (${#new_code[@]}):${C_RESET}"
  for f in "${new_code[@]}"; do echo "     ${C_GREEN}+${C_RESET} ${f/#$HOME/~}"; done
fi

if [ ${#conflict_code[@]} -gt 0 ]; then
  echo ""
  if [ "$FORCE" -eq 1 ] || [ "$BACKUP" -eq 1 ]; then
    if [ "$BACKUP" -eq 1 ]; then
      echo "   ${C_YELLOW}Update existing (${#conflict_code[@]}, .bak backup):${C_RESET}"
    else
      echo "   ${C_RED}Overwrite existing (${#conflict_code[@]}, no backup):${C_RESET}"
    fi
    for f in "${conflict_code[@]}"; do echo "     ${C_YELLOW}⚡${C_RESET} ${f/#$HOME/~}"; done
  else
    echo "   ${C_DIM}Skip (already exist, ${#conflict_code[@]}):${C_RESET}"
    for f in "${conflict_code[@]}"; do echo "     ${C_DIM}- ${f/#$HOME/~}${C_RESET}"; done
    echo "     ${C_DIM}To update: use --backup or --force${C_RESET}"
  fi
fi

if [ ${#new_data[@]} -gt 0 ]; then
  echo ""
  echo "   ${C_GREEN}Initialize data files (${#new_data[@]}):${C_RESET}"
  for f in "${new_data[@]}"; do echo "     ${C_GREEN}+${C_RESET} ${f/#$HOME/~}"; done
fi

if [ ${#existing_data[@]} -gt 0 ]; then
  echo ""
  echo "   ${C_BLUE}Preserve data (untouched, ${#existing_data[@]}):${C_RESET}"
  for f in "${existing_data[@]}"; do echo "     ${C_BLUE}🔒${C_RESET} ${f/#$HOME/~}"; done
fi

# settings.json merge plan
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
WILL_MERGE_SETTINGS=0
if [ "$NO_MERGE" -eq 0 ]; then
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo ""
    echo "   ${C_GREEN}Create settings.json (new):${C_RESET}"
    echo "     ${C_GREEN}+${C_RESET} ~/.claude/settings.json"
    WILL_MERGE_SETTINGS=1
  else
    echo ""
    echo "   ${C_YELLOW}Merge settings.json (add hooks section, .bak backup):${C_RESET}"
    echo "     ${C_YELLOW}⚡${C_RESET} ~/.claude/settings.json"
    WILL_MERGE_SETTINGS=1
  fi
else
  echo ""
  echo "   ${C_DIM}settings.json manual merge (--no-merge-settings):${C_RESET}"
  echo "     ${C_DIM}- You'll need to merge settings.sample.json yourself${C_RESET}"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo ""
  echo "${C_BLUE}🔎 --dry-run mode — no changes made${C_RESET}"
  exit 0
fi

# =============================================================================
# Confirmation
# =============================================================================
if [ "$YES" -eq 0 ]; then
  echo ""
  read -p "${C_BOLD}Proceed? [Y/n]${C_RESET} " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "${C_RED}❌ Cancelled${C_RESET}"
    exit 1
  fi
fi

# =============================================================================
# Execute
# =============================================================================
echo ""
echo "${C_BOLD}3. Installing${C_RESET}"

mkdir -p "$CLAUDE_DIR/hooks" \
         "$CLAUDE_DIR/skills/self-learn" \
         "$CLAUDE_DIR/commands/self-learn" \
         "$CLAUDE_DIR/rules" \
         "$CLAUDE_DIR/self-improvement" \
         "$CLAUDE_DIR/memory"

# CODE files
for entry in "${code_files[@]}"; do
  src="${entry%%|*}"; dst="${entry##*|}"
  if [ -f "$dst" ]; then
    if [ "$FORCE" -eq 1 ] || [ "$BACKUP" -eq 1 ]; then
      if [ "$BACKUP" -eq 1 ]; then
        cp "$dst" "$dst.bak"
      fi
      cp "$src" "$dst"
      echo "   ${C_YELLOW}⚡${C_RESET} updated: ${dst/#$HOME/~}"
    else
      echo "   ${C_DIM}-${C_RESET} skipped: ${dst/#$HOME/~}"
      continue
    fi
  else
    cp "$src" "$dst"
    echo "   ${C_GREEN}+${C_RESET} installed: ${dst/#$HOME/~}"
  fi
  case "$dst" in */hooks/*.sh) chmod +x "$dst" ;; esac
done

# DATA files — never overwrite
for entry in "${data_files[@]}"; do
  src="${entry%%|*}"; dst="${entry##*|}"
  if [ -f "$dst" ]; then
    echo "   ${C_BLUE}🔒${C_RESET} preserved: ${dst/#$HOME/~}"
  else
    cp "$src" "$dst"
    echo "   ${C_GREEN}+${C_RESET} created: ${dst/#$HOME/~}"
  fi
done

# =============================================================================
# settings.json merge
# =============================================================================
if [ "$WILL_MERGE_SETTINGS" -eq 1 ]; then
  echo ""
  echo "${C_BOLD}4. Merging settings.json${C_RESET}"

  SAMPLE="$SCRIPT_DIR/settings.sample.json"

  if [ ! -f "$SETTINGS_FILE" ]; then
    cp "$SAMPLE" "$SETTINGS_FILE"
    echo "   ${C_GREEN}+${C_RESET} created: ~/.claude/settings.json"
  else
    # Backup
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
    echo "   ${C_BLUE}💾${C_RESET} backup: ~/.claude/settings.json.bak"

    # Merge with jq
    # - Append to existing .hooks.* arrays
    # - Compare by script filename (basename) so different command styles
    #   (e.g. "bash $HOME/.claude/hooks/foo.sh" vs "~/.claude/hooks/foo.sh")
    #   are correctly detected as duplicates
    MERGED=$(jq -s '
      def script_name(cmd):
        # Extract any .sh filename from the command string
        (cmd | capture("(?<name>[a-zA-Z0-9_-]+\\.sh)"; "g") | .name) // cmd;

      def merge_hooks(existing; new):
        (existing // []) as $e |
        (new // []) as $n |
        ($e | map(.hooks[]?.command) | map(select(. != null)) | map(script_name(.))) as $existing_names |
        ($n | map(
          .hooks |= map(select(script_name(.command) as $s | $existing_names | index($s) | not))
        ) | map(select(.hooks | length > 0))) as $new_filtered |
        $e + $new_filtered;

      .[0] as $user |
      .[1] as $sample |
      $user
      | .hooks = (.hooks // {})
      | .hooks.SessionStart = merge_hooks(.hooks.SessionStart; $sample.hooks.SessionStart)
      | .hooks.Stop = merge_hooks(.hooks.Stop; $sample.hooks.Stop)
      | .hooks.PostToolUse = merge_hooks(.hooks.PostToolUse; $sample.hooks.PostToolUse)
    ' "$SETTINGS_FILE" "$SAMPLE")

    if [ -n "$MERGED" ]; then
      echo "$MERGED" > "$SETTINGS_FILE"
      echo "   ${C_GREEN}✓${C_RESET} hooks section merged"
    else
      echo "   ${C_RED}✗${C_RESET} merge failed — restore from backup and merge manually"
      echo "     cp $SETTINGS_FILE.bak $SETTINGS_FILE"
      exit 1
    fi
  fi
fi

# =============================================================================
# Success
# =============================================================================
echo ""
echo "${C_BOLD}${C_GREEN}✨ Installation complete!${C_RESET}"
echo ""
echo "${C_BOLD}Next steps:${C_RESET}"
echo "   1. Start a new Claude Code session"
echo "   2. ${C_BLUE}/self-learn:stats${C_RESET}  ← verify installation"
echo "   3. ${C_BLUE}/self-learn${C_RESET}        ← save what you learned at session end"
echo ""
echo "${C_DIM}Uninstall: $SCRIPT_DIR/uninstall.sh${C_RESET}"
echo ""
