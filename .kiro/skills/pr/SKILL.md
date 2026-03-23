---
name: pr
description: Use when the user asks to create a pull request, says "/pr", or wants to open a PR
---

# PR Creation

PRを作成してURL報告するだけのスキル。レビュー・マージは行わない。

## Process

1. `git status`, `git diff --stat`, `git log` でDiff分析
2. エビデンス収集（テスト結果、lint結果等）
3. `git push -u origin $(git branch --show-current)`
4. `gh pr create --title "..." --body "..."` (Conventional Commits形式)
5. PR URLをユーザーに提示

## Rules

- mainブランチから直接PRは作らない
- `--no-verify` や `--force` は使わない
- レビューやマージは行わない — PR作成のみ
