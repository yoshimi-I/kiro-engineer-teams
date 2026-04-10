
# レビュー指摘の自動修正ループ

ユーザーの指示を待たず、即座にレビュー指摘のあるPRを自動検出して修正を開始する。PRのレビューコメント（🔴 修正必須）を自動取得し、指摘を1つずつ修正→push→再レビュー待ちを繰り返す。

## 1サイクルの処理

### Step 1: 修正が必要なPRを検出

まず `reviewDecision` で CHANGES_REQUESTED のPRを検出する:
```bash
gh pr list --json number,title,headRefName,reviewDecision --limit 20
```
`reviewDecision` が `CHANGES_REQUESTED` のPRを対象にする。

次に、対象PRのレビューコメントとPRコメントの両方から指摘内容を取得する:
```bash
gh pr view <number> --json reviews,comments
```
「🔴 修正必須」または「🔴 マージ失敗」を含むレビュー/コメントから指摘を抽出する。

**重要**: `reviewDecision` が `CHANGES_REQUESTED` であれば、コメント内に「🔴 修正必須」の文字列がなくても修正対象とする。レビュー本文（reviews）にも指摘が含まれている場合があるため、comments だけでなく reviews も必ず確認すること。

対象がなければ「監視継続中。」で終了（次サイクルで再チェック）。

### Step 2: 指摘内容の取得と理解

#### コンフリクト（🔴 マージ失敗）の場合
1. `git fetch origin` → `git rebase origin/main`
2. コンフリクトを解決（`/resolve-conflicts` の手順に従う）
3. `git push --force-with-lease origin $(git branch --show-current)`
4. PRにコメント: 「コンフリクトを解決しました。再マージをお願いします。」
5. 以降のStepはスキップ

#### レビュー指摘（🔴 修正必須）の場合
1. レビューコメントから指摘事項を抽出（ファイル、行、カテゴリ、修正案）
2. 指摘されたファイルと行を実際に読む
3. 修正案が正しいか検証

### Step 3: 修正の実施
1. 対象ブランチをチェックアウト
2. 指摘を1つずつ修正する
3. 修正案を鵜呑みにしない。間違っている場合は自分で正しい修正を考える

### Step 4: 検証
steering ファイルからプロジェクトの検証コマンドを確認し、実行する。
1つでも失敗したら修正をやり直す。

### Step 5: コミット & Push
```bash
git add -A
git commit -m "fix: レビュー指摘を修正"
git push origin $(git branch --show-current)
```

### Step 6: PRにコメント
```bash
gh pr comment <number> --body "レビュー指摘を修正しました。再レビューをお願いします。"
```

### Step 7: 再レビュー結果を確認し、APPROVEならマージ
修正push後、再レビューの結果を確認する。
```bash
gh pr view <number> --json reviewDecision --jq '.reviewDecision'
```
- `APPROVED` → 即座にマージ:
  ```bash
  gh pr merge <number> --squash --delete-branch
  ```
  マージ失敗時はPRにコメント:
  ```bash
  gh pr comment <number> --body "🔴 マージ失敗: コンフリクトが発生。リベースが必要です。"
  ```
- `CHANGES_REQUESTED` → Step 2 に戻って再修正
- まだレビューされていない → 次のPRへ進む（次サイクルで再確認）

## ループ停止条件

| 条件 | 動作 |
|------|------|
| 修正必要PRが0件 | APPROVEDでマージ待ちのPRを探してマージ（後述）→ 終了 |
| ユーザーが「止めて」と言った | 即座に停止 |
| 同じPRで3回修正しても🔴が残る | PRにコメントして人間にエスカレーション |

## 修正対象がない場合: マージ待ちPRの処理

修正が必要なPRが0件の場合、APPROVEDでまだマージされていないPRを探して積極的にマージする。

```bash
gh pr list --json number,title,headRefName,reviewDecision --limit 20
```

`reviewDecision` が `APPROVED` のPRがあれば:
```bash
gh pr merge <number> --squash --delete-branch
```

マージ失敗時はコメントしてリベース対応:
```bash
gh pr comment <number> --body "🔴 マージ失敗: コンフリクトが発生。リベースが必要です。"
```

## ルール

- 修正案を鵜呑みにしない
- 指摘と無関係な変更を混ぜない
- 検証が通らない修正は push しない
- 他のエージェントが着手中のPRは触らない（task.md確認）
