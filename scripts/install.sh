#!/usr/bin/env bash
# Install kiro-engineer-teams into an existing project.
# Usage: curl -fsSL <raw-url>/scripts/install.sh | bash
#    or: bash <(curl -fsSL <raw-url>/scripts/install.sh)

set -euo pipefail

REPO="yoshimi-I/kiro-engineer-teams"
BRANCH="main"
BOLD='\033[1m' DIM='\033[2m' GREEN='\033[32m' RED='\033[31m' YELLOW='\033[33m' RESET='\033[0m'

info()  { echo -e "${GREEN}  ✔ $1${RESET}"; }
warn()  { echo -e "${YELLOW}  ⚠ $1${RESET}"; }
fail()  { echo -e "${RED}  ✗ $1${RESET}"; exit 1; }

echo ""
echo -e "${BOLD}  📦 Install kiro-engineer-teams${RESET}"
echo -e "${DIM}  Add 8-agent pipeline to your existing project${RESET}"
echo ""

# ── Preflight ──
[[ ! -d ".git" ]] && fail "Not a git repository. Run from your project root."

# ── Clone to temp dir ──
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TMPDIR" 2>/dev/null

# ── Copy files ──
copy_dir() {
  local src="$TMPDIR/$1"
  [[ ! -d "$src" ]] && return
  if [[ -d "$1" ]]; then
    warn "$1/ already exists — merging (won't overwrite existing files)"
    cp -rn "$src" "$(dirname "$1")/"
  else
    cp -r "$src" "$1"
    info "$1/"
  fi
}

copy_file() {
  local src="$TMPDIR/$1"
  [[ ! -f "$src" ]] && return
  if [[ -f "$1" ]]; then
    warn "$1 already exists — skipped"
  else
    mkdir -p "$(dirname "$1")"
    cp "$src" "$1"
    info "$1"
  fi
}

echo -e "${BOLD}  Copying files...${RESET}"
echo ""

copy_dir ".kiro"
copy_dir "scripts"
copy_file "justfile"
copy_file "AGENTS.md"
copy_file "skills-lock.json"

# Make scripts executable
chmod +x scripts/*.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}  ✔ Installation complete!${RESET}"
echo ""
echo -e "  Next steps:"
echo -e "    ${DIM}1.${RESET} just setup  ${DIM}# install prerequisites${RESET}"
echo -e "    ${DIM}2.${RESET} just start  ${DIM}# start INCEPTION + pipeline${RESET}"
echo ""
