
# 8-Agent 並列自動化パイプライン

8つのKiro CLIセッションを並列で起動し、issue→実装→レビュー→マージ→検証の全サイクルを自動化する。

## アーキテクチャ

```
[Agent 1] /implement ──────── issue→実装→PR作成
[Agent 2] /implement ──────── 同上（並列で別issue）
[Agent 3] /review ─────────── open PR→厳格レビュー→マージ
[Agent 4] /fix-review-issues── 🔴指摘→修正→再push
[Agent 5] /fix-ci ─────────── CI失敗→ログ解析→修正→再push
[Agent 6] /watch-main ─────── mainマージ検出→E2E検証→バグissue
[Agent 7] /e2e-bug-hunt ───── Playwright巡回→バグissue
[Agent 8] /improve ─────────── コード分析→改善issue自動生成

共有状態: issue/task.md
```

## データフロー

```
GitHub Issue
    │
    ▼
Agent 1,2: /implement ──→ PR作成
                             │
                             ▼
                       Agent 3: /review
                             │
                        ┌────┴────┐
                     🟢 LGTM   🔴 修正必須
                        │         │
                        ▼         ▼
                   merge    Agent 4: /fix-review-issues
                        │         │
                        │    修正→push→Agent 3が再レビュー
                        │
                        ▼
                   Agent 5: /fix-ci（CI失敗時）
                        │
                        ▼
                   main にマージ
                        │
                        ▼
                   Agent 6: /watch-main（E2E検証）
                        │
                   バグ発見? → Yes → issue作成 → Agent 1,2 が拾う
                                        ▲
                                        │
                   Agent 7: /e2e-bug-hunt（Playwright巡回）

Agent 8: /improve（10分間隔で改善issue自動生成）
```

## 起動方法

8つのターミナルでそれぞれ起動:

```bash
# Terminal 1-2: 実装エージェント
kiro-cli chat → /implement

# Terminal 3: レビューエージェント
kiro-cli chat → /review

# Terminal 4: レビュー指摘修正エージェント
kiro-cli chat → /fix-review-issues

# Terminal 5: CI修正エージェント
kiro-cli chat → /fix-ci

# Terminal 6: mainブランチ監視エージェント
kiro-cli chat → /watch-main

# Terminal 7: E2Eバグハントエージェント
kiro-cli chat → /e2e-bug-hunt

# Terminal 8: 改善issue自動生成エージェント
kiro-cli chat → /improve
```

## 各エージェントの役割

| # | プロンプト | 役割 | ポーリング間隔 |
|---|-----------|------|---------------|
| 1 | `/implement` | issueを取って実装→PR作成（ループ） | 即座に次へ |
| 2 | `/implement` | 同上（並列で別issue） | 即座に次へ |
| 3 | `/review` | open PRを取得→厳格レビュー→マージ | 即座に次へ |
| 4 | `/fix-review-issues` | 🔴指摘のあるPRを修正→再push | 2分 |
| 5 | `/fix-ci` | CI失敗PRを検出→修正→再push | 2分 |
| 6 | `/watch-main` | mainマージ検出→テスト+E2E検証→バグissue | 2分 |
| 7 | `/e2e-bug-hunt` | Playwright全ページ巡回→バグissue | サイクル完了後 |
| 8 | `/improve` | コード分析→改善issue自動生成 | 10分 |

## 競合回避

全エージェントは `issue/task.md` を共有状態として使う:

- `/implement` は着手前に task.md を読み、他エージェントと重複しないissueを選ぶ
- `/fix-review-issues` と `/fix-ci` は同じPRを同時に触らない
- `/review` はレビューのみ行い、コードを変更しない（競合しない）
- `/watch-main` と `/e2e-bug-hunt` はissue作成のみ（競合しない）

## エスカレーション

| エージェント | エスカレーション条件 | 方法 |
|------------|-------------------|------|
| `/fix-review-issues` | 3回修正しても🔴 | PRにコメント |
| `/fix-ci` | 3回修正してもCI失敗 | PRにコメント |
| `/improve` | 改善ポイントが見つからない | スキップして次サイクルへ |
| `/e2e-bug-hunt` | アプリ起動不能 | 報告して停止 |
