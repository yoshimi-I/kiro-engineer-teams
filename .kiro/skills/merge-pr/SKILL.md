---
name: merge-pr
description: 「PRマージして」「mainにマージ」と言われたとき、PR作成→CI確認→mainへスカッシュマージまで一気通貫で行う
---

# PR作成→mainマージ

現在の変更からPR作成→CI確認→mainへスカッシュマージまでを一気通貫で行う。

## 手順

1. `git status`, `git diff` で変更確認
2. ブランチ作成（feat/fix/chore/docs）
3. コミット（Conventional Commits形式）
4. `git push` → `gh pr create`
5. `gh pr checks --watch` でCI確認
6. CI全パス → `gh pr merge --squash --delete-branch`
7. ローカルmainを最新に同期

## ルール

- CIが通らないコード変更をマージしない
- 1 PR = 1つの論理的な変更単位
- PRタイトルはConventional Commits形式
