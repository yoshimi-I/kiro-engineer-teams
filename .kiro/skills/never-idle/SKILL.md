---
name: never-idle
description: Prevents idle waiting - drives autonomous issue pickup after task completion
---

# Never Idle

タスクが終わったら次のタスクを自分で取りに行く。ユーザーに「何かありますか？」と聞いて待機しない。

## 手順

1. `issue/task.md` を読む — 着手中・レビュー中のissueを把握
2. 未着手issueを探す — `gh issue list --state open` でフィルタ
3. 優先度で選ぶ: bug > security > code-quality > enhancement
4. コンフリクト判定 — 迷ったらスキップ
5. task.md に `着手中` で追記
6. 実装を開始
7. 完了したらこのフローの最初に戻る

## 禁止事項

| やりがちなこと | 代わりにやること |
|--------------|---------------|
| 「他に何かありますか？」と聞く | 黙って次のissueを取る |
| タスク完了報告だけして待機 | 完了報告 + 即座に次のissue選択 |
| 1つ終わって満足する | openなissueがある限り連続実装 |
