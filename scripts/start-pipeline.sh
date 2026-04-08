#!/usr/bin/env bash
# 8-Agent Pipeline Launcher
#
# Phase 1: Brainstorm — design with user → create issues
# Phase 2: Pipeline — launch 8 agents in zellij
#
# Usage: ./scripts/start-pipeline.sh

set -euo pipefail

# ── Preflight ──
for cmd in kiro-cli zellij gh; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Required: $cmd"
    exit 1
  fi
done

if [[ ! -d ".kiro/prompts" ]]; then
  echo "❌ Run from project root (no .kiro/prompts/ found)"
  exit 1
fi

if ! git remote get-url origin &>/dev/null; then
  echo "❌ git remote 'origin' is not configured"
  echo "   Run: git remote add origin <repo-url>"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI is not authenticated"
  echo "   Run: gh auth login"
  exit 1
fi

# ── Ensure task.md ──
mkdir -p issue
if [[ ! -f "issue/task.md" ]]; then
  cat > issue/task.md << 'TMPL'
# Issue Tracker

| Issue | Title | Status | Branch |
|-------|-------|--------|--------|
| #999 | (example) feat: add feature | in-progress / in-review / merged / resolved | feat/issue-999-xxx |
TMPL
fi

# ── Phase 1: Brainstorm ──
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 1: Brainstorming"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Kiro CLI will start."
echo "  Tell it what you want to build."
echo "  After design is finalized, issues will be created."
echo "  Type /quit to exit and launch the pipeline."
echo ""
echo "  Tips:"
echo "    - /brainstorming starts the design flow"
echo "    - /create-issue creates issues from the design"
echo "    - /quit exits to launch the pipeline"
echo ""
read -p "  Press Enter to start → " _

kiro-cli chat

# ── Check issues exist ──
ISSUE_COUNT=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
if [[ "$ISSUE_COUNT" -eq 0 ]]; then
  echo ""
  echo "⚠️  No open issues found."
  read -p "  Launch pipeline anyway? (y/N) → " yn
  [[ "$yn" != "y" && "$yn" != "Y" ]] && echo "Aborted." && exit 0
fi

# ── Phase 2: Pipeline ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 2: 8-Agent Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📋 Open issues: ${ISSUE_COUNT}"
echo ""
echo "  🔨 Impl-1, Impl-2  → pick issues and implement"
echo "  🔍 Review           → review PRs → merge"
echo "  🔧 Fix-Review       → fix review comments"
echo "  🚦 Fix-CI           → fix CI failures"
echo "  👀 Watch-Main       → E2E verification after merge"
echo "  🧪 E2E-Hunt         → Playwright patrol"
echo "  📦 Dependabot       → dependency update PRs"
echo ""
echo "  Each agent waits for work and starts automatically."
echo ""

zellij --layout scripts/pipeline.kdl
