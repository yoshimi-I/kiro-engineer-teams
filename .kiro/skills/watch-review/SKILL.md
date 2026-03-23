---
name: watch-review
description: Use when the user says "PR監視", "レビュー監視", or wants to continuously monitor open PRs, auto-review, and squash-merge clean PRs
---

# PR監視・自動レビュー・マージ

open PRをポーリングし、未レビューPRを厳格レビュー → 指摘ゼロならスカッシュマージ、指摘ありならサブエージェントで自動修正。

## 1サイクルの処理

### Step 1: Open PR取得
```bash
gh pr list --state open --json number,title,headRefName,reviewDecision,author --limit 20
```

### Step 2: CI/CDステータス確認
```bash
gh pr view {number} --json mergeStateStatus,mergeable
```

| mergeStateStatus | アクション |
|-----------------|-----------|
| `CLEAN` | マージ可能（唯一マージしてよい状態） |
| `UNSTABLE` | CI失敗。絶対にマージ禁止。CIログ確認→修正 |
| `DIRTY` | コンフリクトあり。`/rebase-prs` で自動リベース |
| `UNKNOWN` | スキップ（次サイクルで再確認） |

### Step 3: 厳格レビュー
`/review` スキルの5視点で分析。信頼度80以上の指摘のみ報告。

### Step 4: 結果に基づくアクション

- 指摘ゼロ → approve → squash merge → task.md `merge済み`
- 指摘あり → サブエージェントで自動修正（最大3回ループ）→ 再レビュー → merge
- 3回超過 → request changes → task.md `差し戻し`（人間エスカレーション）

## Common Mistakes

- CI失敗中（UNSTABLE）のPRをマージする → 最も致命的なミス
- diffだけ読んでLGTM → 呼び出し元追跡、境界値検証を必ず行う
- force merge → 必ずsquash merge + delete branch
