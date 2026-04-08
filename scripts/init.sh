#!/usr/bin/env bash
# Initialize cloned template as your own private repo
# Usage: ./scripts/init.sh <repo-name>
set -euo pipefail

REPO="${1:-$(basename "$PWD")}"

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
