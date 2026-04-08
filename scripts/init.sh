#!/usr/bin/env bash
# Initialize cloned template as your own private repo
# Usage: ./scripts/init.sh [repo-name]
set -euo pipefail

REPO="${1:-$(basename "$PWD")}"

echo "📦 リポジトリ名: $REPO"
read -p "   この名前でOK？ (Y/n/別名を入力) → " answer

case "$answer" in
  ""|[Yy]) ;;  # そのまま
  [Nn]) echo "中止しました。"; exit 0 ;;
  *) REPO="$answer" ;;
esac

# Check if repo already exists on GitHub
if gh repo view "$REPO" &>/dev/null; then
  echo "⚠️  Repository '$REPO' already exists on GitHub."
  echo "   削除: gh repo delete $REPO --yes"
  echo "   別名: just init <other-name>"
  exit 1
fi

# Remove template files
rm -f LICENSE
rm -rf docs
for f in README.md AGENTS.md; do
  if grep -q "kiro-engineer-teams" "$f" 2>/dev/null; then
    rm -f "$f"
  fi
done

# Remove template git history
rm -rf .git
git init
git add .
git commit -m "init: scaffold from kiro-engineer-teams"

# Create private GitHub repo and push
gh repo create "$REPO" --private --source=. --push

echo ""
echo "🎉 Created private repo: $REPO"
echo "   Run: just start"
