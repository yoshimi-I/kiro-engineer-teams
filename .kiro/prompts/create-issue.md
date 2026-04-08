
# Issue作成スキル — 実装者が迷わない詳細issueを書く

## Philosophy

issueの質 = 実装速度。「調査済み・方針決定済み・ファイルパス特定済み」のissueを書く。

## Process

### Step 1: 要望の明確化
- 何を実現したいか、なぜ必要か、スコープを整理
- 不明点は選択肢とメリデメを提示して質問。丸投げの質問は禁止

### Step 2: コードベース徹底調査
最低5ファイル以上読んでからissueを書く:
1. 変更対象ファイル
2. 呼び出し元/依存先
3. 型定義・インターフェース
4. 既存の類似実装
5. テストファイル

### Step 3: 既存issue重複チェック
```bash
gh issue list --state open --limit 50 --json number,title
gh issue list --state closed --limit 30 --json number,title
```

### Step 4: Issue本文作成
実装者が読むだけで実装に入れるレベルで書く:
- 概要、背景・動機、現状の実装
- 変更方針（ファイルパス付きチェックリスト）
- テスト、技術的な注意事項、影響範囲、受け入れ条件

### Step 5: ラベル選定・Issue作成
`gh issue create` で作成。タイトルはConventional Commits準拠。

## Rules

- 調査せずにissueを書かない。最低5ファイルは読む
- 変更方針のチェックリストは必ずファイルパス付き
- 大きすぎるissueは分割する。1 issue = 1 PR で完結するスコープに
