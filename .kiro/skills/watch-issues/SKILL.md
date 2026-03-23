---
name: watch-issues
description: Use when the user says "issue監視", "issue自動実装", or wants to continuously monitor GitHub issues and auto-implement them
---

# GitHub Issue監視・自動実装

GitHub issueをポーリングし、新issueを検出次第サブエージェントで自動実装→PR作成まで行う。

## 状態管理

`issue/task.md` で進捗を管理。テーブルにないissue = 未着手 = 実装対象。

## 1サイクルの処理

1. `gh issue list --state open --json number,title,body,labels --limit 30`
2. `issue/task.md` と照合し、未処理issue特定
3. 新issueなし → 「監視継続中。」で終了
4. 新issueあり → task.mdを`着手中`で更新 → サブエージェントで実装ディスパッチ（最大3件/サイクル）
5. 完了後にtask.md確認

## Common Mistakes

- ユーザー承認を求める → 完全自動
- task.md更新前にディスパッチ → 必ず先に着手中を書く
- 全issueを1つのPRにまとめる → 1 issue = 1 PR
- 一度に大量ディスパッチ → 最大3件/サイクル
