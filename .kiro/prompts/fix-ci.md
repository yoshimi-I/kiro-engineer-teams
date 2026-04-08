
# CI失敗自動修正ループ

CI（GitHub Actions）が失敗しているPRを検出し、ログを読んで修正→再pushを繰り返す。

## 1サイクルの処理

### Step 1: CI失敗PRを検出
```bash
gh pr list --json number,title,headRefName,statusCheckRollup --jq '.[] | select(.statusCheckRollup[]?.conclusion == "FAILURE")'
```
CI失敗PRがなければ「監視継続中。」で2分待機→再チェック。

### Step 2: 失敗ログを取得
```bash
gh run list --branch <branch> --status failure --json databaseId,name --limit 5
gh run view <run-id> --log-failed
```

### Step 3: エラー分類と修正

| エラー種別 | 修正方法 |
|-----------|---------|
| lint/format エラー | lint/formatコマンドを実行して自動修正 |
| 型エラー | エラー箇所のファイルを読み、型を修正 |
| テスト失敗 | 失敗テストを読み、実装 or テストを修正 |
| ビルドエラー | import漏れ、依存関係、構文エラーを修正 |
| 環境・設定エラー | CI設定ファイルを確認・修正 |

### Step 4: 修正の実施
1. 対象ブランチをチェックアウト
2. エラー箇所を修正
3. steering ファイルから検証コマンドを確認してローカル実行
4. コミット&push:
   ```bash
   git add -A
   git commit -m "fix: CI失敗を修正 — <エラー概要>"
   git push origin <branch>
   ```

### Step 5: CI再実行を確認
```bash
gh run watch --exit-status
```
- 成功 → 次のCI失敗PRへ
- 再度失敗 → Step 2に戻る（最大3回まで）
- 3回失敗 → PRにコメントして人間にエスカレーション

## ループ停止条件

| 条件 | 動作 |
|------|------|
| CI失敗PRが0件 | 2分待機して再チェック（常駐） |
| ユーザーが「止めて」と言った | 即座に停止 |

## ルール

- 修正は最小限。CI通過に必要な変更だけ行う
- 機能変更・リファクタリングは行わない
- 3回修正しても通らない場合は人間にエスカレーション
- 他のエージェントが着手中のPRは触らない（task.md確認）
- Dependabot PRのCI失敗は `/auto-dependabot` に任せる
