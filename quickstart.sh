#!/bin/bash
# quickstart.sh — one-line installer for claude-self-learn
#
# Usage (paste in terminal):
#   curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
#
# This script:
#   1. Detects your OS (macOS / Linux / WSL / Git Bash on Windows)
#   2. Checks for / installs jq (with your confirmation)
#   3. Downloads the latest release from GitHub (no git required)
#   4. Runs install.sh --yes (which is safe — skips existing files, backs up settings.json)
#   5. Cleans up temp files

set -e

REPO="DAYLAB-HQ/claude-self-learn"
TARBALL_URL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
TMP_DIR="$(mktemp -d -t claude-self-learn-XXXXXX)"

# Colors
if [ -t 1 ]; then
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'
  C_RESET=$'\033[0m'
else
  C_BOLD=''; C_DIM=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''; C_RESET=''
fi

cleanup() {
  [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo ""
echo "${C_BOLD}${C_BLUE}╔═══════════════════════════════════════════════╗${C_RESET}"
echo "${C_BOLD}${C_BLUE}║  claude-self-learn · one-line installer      ║${C_RESET}"
echo "${C_BOLD}${C_BLUE}╚═══════════════════════════════════════════════╝${C_RESET}"
echo ""

# ============================================================================
# 1. Detect OS
# ============================================================================
OS="unknown"
case "$(uname -s)" in
  Darwin*)
    OS="macos"
    ;;
  Linux*)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      OS="wsl"
    else
      OS="linux"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    OS="gitbash"
    ;;
esac

echo "${C_BOLD}1. Environment${C_RESET}"
echo "   OS: $OS"

if [ "$OS" = "unknown" ]; then
  echo "   ${C_RED}✗${C_RESET} Could not detect your OS."
  echo "   Please file an Issue at https://github.com/$REPO/issues with the output of \`uname -a\`."
  exit 1
fi

# ============================================================================
# 2. Check / install jq
# ============================================================================
if command -v jq &>/dev/null; then
  echo "   ${C_GREEN}✓${C_RESET} jq is already installed"
else
  echo "   ${C_YELLOW}!${C_RESET} jq is not installed (required for JSON processing)"
  echo ""

  case "$OS" in
    macos)
      if command -v brew &>/dev/null; then
        echo "   ${C_BOLD}Install jq via Homebrew now? [Y/n]${C_RESET} "
        read -n 1 -r REPLY </dev/tty
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
          brew install jq
        else
          echo "${C_RED}Please install jq manually, then re-run this script.${C_RESET}"
          exit 1
        fi
      else
        echo "${C_RED}   ✗ Homebrew not found.${C_RESET}"
        echo "   Install Homebrew first: https://brew.sh"
        echo "   Then run this installer again."
        exit 1
      fi
      ;;
    linux|wsl)
      if command -v apt-get &>/dev/null; then
        echo "   ${C_BOLD}Install jq via apt now? [Y/n]${C_RESET} "
        read -n 1 -r REPLY </dev/tty
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
          sudo apt-get update -qq && sudo apt-get install -y jq
        else
          echo "${C_RED}Please install jq manually (e.g. sudo apt install jq), then re-run.${C_RESET}"
          exit 1
        fi
      elif command -v yum &>/dev/null; then
        sudo yum install -y jq
      elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm jq
      else
        echo "${C_RED}   ✗ Couldn't find a supported package manager.${C_RESET}"
        echo "   Please install jq manually and re-run this script."
        exit 1
      fi
      ;;
    gitbash)
      echo "${C_YELLOW}   ! jq isn't auto-installable in Git Bash on Windows.${C_RESET}"
      echo "   Download jq binary from: https://jqlang.github.io/jq/download/"
      echo "   Place jq.exe somewhere in your PATH, then re-run this script."
      exit 1
      ;;
  esac
fi

# ============================================================================
# 3. Download latest release tarball
# ============================================================================
echo ""
echo "${C_BOLD}2. Download${C_RESET}"
echo "   Fetching latest version from github.com/$REPO ..."

if ! command -v curl &>/dev/null; then
  echo "${C_RED}   ✗ curl not found. Please install curl and re-run.${C_RESET}"
  exit 1
fi

cd "$TMP_DIR"
if ! curl -sSL "$TARBALL_URL" -o release.tar.gz; then
  echo "${C_RED}   ✗ Download failed.${C_RESET}"
  echo "   Check your internet connection or try the manual install:"
  echo "     https://github.com/$REPO#manual-install"
  exit 1
fi

if ! tar -xzf release.tar.gz; then
  echo "${C_RED}   ✗ Extraction failed (corrupted download?).${C_RESET}"
  exit 1
fi

# Find extracted dir (should be one subdirectory like "claude-self-learn-main")
EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -not -path "$TMP_DIR" | head -1)
if [ -z "$EXTRACTED_DIR" ] || [ ! -f "$EXTRACTED_DIR/install.sh" ]; then
  echo "${C_RED}   ✗ Expected install.sh not found in download.${C_RESET}"
  exit 1
fi

echo "   ${C_GREEN}✓${C_RESET} Downloaded to $TMP_DIR"

# ============================================================================
# 4. Run install.sh
# ============================================================================
echo ""
echo "${C_BOLD}3. Install${C_RESET}"
echo ""

cd "$EXTRACTED_DIR"
chmod +x install.sh
./install.sh --yes

# ============================================================================
# 5. Done
# ============================================================================
echo ""
echo "${C_BOLD}${C_GREEN}🎉 All done!${C_RESET}"
echo ""
echo "Open a ${C_BOLD}new${C_RESET} Claude Code session and try:"
echo "   ${C_BLUE}/self-learn:stats${C_RESET}   — see your current memories"
echo "   ${C_BLUE}/self-learn${C_RESET}         — save what you learned at session end"
echo ""
echo "${C_DIM}Repo: https://github.com/$REPO${C_RESET}"
echo ""
