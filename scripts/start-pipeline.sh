#!/usr/bin/env bash
# 8-Agent Pipeline Launcher
#
# Phase 1: INCEPTION — structured planning with AI-DLC workflow
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

# ── Ensure directories ──
mkdir -p issue aidlc-docs/inception

if [[ ! -f "issue/task.md" ]]; then
  cat > issue/task.md << 'TMPL'
# Issue Tracker

| Issue | Title | Status | Branch |
|-------|-------|--------|--------|
| #999 | (example) feat: add feature | in-progress / in-review / merged / resolved | feat/issue-999-xxx |
TMPL
fi

# ── Phase 1: INCEPTION (skip if already completed) ──
INCEPTION_DONE=false
if [[ -d "aidlc-docs/inception" ]] && ls aidlc-docs/inception/*/*.md &>/dev/null 2>&1; then
  ISSUE_COUNT=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
  if [[ "$ISSUE_COUNT" -gt 0 ]]; then
    INCEPTION_DONE=true
  fi
fi

if [[ "$INCEPTION_DONE" == "true" ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  ✅ INCEPTION already completed"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  📄 Artifacts: aidlc-docs/inception/"
  echo "  📋 Open issues: ${ISSUE_COUNT}"
  echo ""
  echo "  Skipping INCEPTION → launching pipeline directly."
  echo ""
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Phase 1: INCEPTION (AI-DLC)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Kiro CLI will start with the INCEPTION workflow."
  echo "  This guides you through:"
  echo ""
  echo "    1. Workspace Detection"
  echo "    2. Requirements Analysis"
  echo "    3. User Stories (if needed)"
  echo "    4. Architecture Design (if needed)"
  echo "    5. Issue Generation (automatic)"
  echo ""
  echo "  After issues are created, type /quit to launch the pipeline."
  echo ""
  echo "  ⚠️  INCEPTION が完了したら /quit と入力してこの画面を抜けてください。"
  echo "      パイプラインが自動で起動します。"
  echo ""
  read -p "  Press Enter to start → " _

  kiro-cli chat --trust-all-tools "/inception"

  # ── Push INCEPTION artifacts to main ──
  INCEPTION_FILES=$(git ls-files --others --modified -- aidlc-docs/ issue/ .kiro/steering/ 2>/dev/null)
  if [[ -n "$INCEPTION_FILES" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  INCEPTION artifacts detected:"
    echo "$INCEPTION_FILES" | sed 's/^/    /'
    echo ""
    read -p "  Push to main so pipeline agents can access them? (Y/n) → " yn
    if [[ "$yn" != "n" && "$yn" != "N" ]]; then
      git add aidlc-docs/ issue/ .kiro/steering/
      git commit -m "docs: add INCEPTION artifacts"
      git push origin main
      echo "  ✔ Pushed to main."
    else
      for pattern in aidlc-docs/ issue/; do
        grep -qxF "$pattern" .gitignore 2>/dev/null || echo "$pattern" >> .gitignore
      done
      echo "  ✔ Added aidlc-docs/ and issue/ to .gitignore."
    fi
  fi

  ISSUE_COUNT=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
fi

# ── Check issues exist ──
if [[ -z "${ISSUE_COUNT:-}" ]]; then
  ISSUE_COUNT=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
fi
if [[ "$ISSUE_COUNT" -eq 0 ]]; then
  echo ""
  echo "⚠️  No open issues found."
  read -p "  Launch pipeline anyway? (y/N) → " yn
  [[ "$yn" != "y" && "$yn" != "Y" ]] && echo "Aborted." && exit 0
fi

# ── Phase 2: Pipeline ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 2: 10-Agent Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📋 Open issues: ${ISSUE_COUNT}"
echo ""
echo "  🖥️  Dev-Server       → keep dev servers running"
echo "  🔨 Impl-1, Impl-2  → pick issues and implement"
echo "  🔍 Review-1, Review-2 → review PRs → merge"
echo "  🔧 Fix-Review-1, Fix-Review-2 → fix review comments"
echo "  👀 Watch-Main       → E2E verification after merge"
echo "  🧪 E2E-Hunt         → Playwright patrol"
echo "  💡 Improve          → auto-generate improvement issues"
echo ""
echo "  Each agent waits for work and starts automatically."
echo ""

zellij --layout scripts/pipeline.kdl
