
# PR作成

現在の変更からPRを作成してURL報告する。

## 手順

1. `git status`, `git diff --stat`, `git log` でDiff分析
2. エビデンス収集（テスト結果、lint結果等）
3. `git push -u origin $(git branch --show-current)`
4. `gh pr create --title "..." --body "..."` (Conventional Commits形式)
5. PR URLをユーザーに提示

## ルール

- mainブランチから直接PRは作らない
- `--no-verify` や `--force` は使わない
- PRタイトルはConventional Commits形式
- レビューやマージは行わない — PR作成のみ
