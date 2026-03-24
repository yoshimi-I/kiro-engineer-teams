---
name: pr
description: PRを作成したいとき、「PR作って」と言われたときに使用する
---

# PR作成

PRを作成してURL報告するだけのスキル。レビュー・マージは行わない。

## 手順

1. `git status`, `git diff --stat`, `git log` でDiff分析
2. エビデンス収集（テスト結果、lint結果等）
3. `git push -u origin $(git branch --show-current)`
4. `gh pr create --title "..." --body "..."` (Conventional Commits形式)
5. PR URLをユーザーに提示

## ルール

- mainブランチから直接PRは作らない
- `--no-verify` や `--force` は使わない
- レビューやマージは行わない — PR作成のみ
