#!/usr/bin/env bash
# 8-Agent Pipeline Launcher
#
# Phase 1: ブレスト — ユーザーと対話して設計→issue作成
# Phase 2: パイプライン — zellijで8エージェント並列起動
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
  echo "❌ git remote 'origin' が未設定です"
  echo "   git remote add origin <repo-url> を実行してください"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "❌ GitHub CLI が未認証です"
  echo "   gh auth login を実行してください"
  exit 1
fi

# ── Ensure task.md ──
mkdir -p issue
if [[ ! -f "issue/task.md" ]]; then
  cat > issue/task.md << 'TMPL'
# Issue Tracker
<!-- ⚠️ このヘッダーと記入例の行は削除禁止 -->

| Issue | タイトル | ステータス | ブランチ |
|-------|---------|-----------|---------| 
| #999 | （記入例）feat: 〇〇機能追加 | 着手中 / レビュー中 / merge済み / 解決済み（変更不要） | feat/issue-999-xxx |
TMPL
fi

# ── Phase 1: Brainstorm ──
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 1: ブレインストーミング"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Kiro CLIが起動します。"
echo "  作りたいものの概要を伝えてください。"
echo "  設計が固まったらissueを作成してもらい、"
echo "  /quit で抜けるとパイプラインが起動します。"
echo ""
echo "  💡 Tips:"
echo "    - /brainstorming で設計フローが始まります"
echo "    - 設計完了後 /create-issue でissue作成"
echo "    - issueができたら /quit で次のフェーズへ"
echo ""
read -p "  Enter で開始 → " _

kiro-cli chat

# ── Check issues exist ──
ISSUE_COUNT=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
if [[ "$ISSUE_COUNT" -eq 0 ]]; then
  echo ""
  echo "⚠️  Open issueが0件です。"
  read -p "  パイプラインを起動しますか？ (y/N) → " yn
  [[ "$yn" != "y" && "$yn" != "Y" ]] && echo "中止しました。" && exit 0
fi

# ── Phase 2: Pipeline ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 2: 8-Agent パイプライン起動"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  📋 Open issues: ${ISSUE_COUNT}件"
echo ""
echo "  🔨 Impl-1, Impl-2  → issueを取って実装"
echo "  🔍 Review           → PRをレビュー→マージ"
echo "  🔧 Fix-Review       → レビュー指摘を修正"
echo "  🚦 Fix-CI           → CI失敗を修正"
echo "  👀 Watch-Main       → mainマージ後E2E検証"
echo "  🧪 E2E-Hunt         → Playwright巡回"
echo "  📦 Dependabot       → 依存更新PR処理"
echo ""
echo "  各エージェントはissue/PRが来るまで待機し、"
echo "  仕事が発生次第、自動で動き始めます。"
echo ""

zellij --layout scripts/pipeline.kdl
