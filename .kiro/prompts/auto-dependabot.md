
# Dependabot PR自動処理ループ

Dependabotが作成した依存関係更新PRを検出し、CI通過→自動マージ / CI失敗→closeを行う。

## 1サイクルの処理

### Step 1: Dependabot PRを検出
```bash
gh pr list --author "app/dependabot" --json number,title,headRefName,statusCheckRollup
```
対象がなければ「監視継続中。」で5分待機→再チェック。

### Step 2: 各PRのCI状態を確認
```bash
gh pr checks <number>
```

| CI状態 | アクション |
|--------|-----------|
| 全通過 | Step 3（マージ判断）へ |
| 失敗 | Step 4（修正試行 or close）へ |
| 未完了 | スキップ |

### Step 3: マージ判断
1. PR本文からsemverの変更レベルを確認:
   - patch (x.x.X) → 自動マージ
   - minor (x.X.0) → 自動マージ
   - major (X.0.0) → PRにコメントして人間にエスカレーション
2. マージ実行:
   ```bash
   gh pr merge <number> --squash --delete-branch
   ```

### Step 4: CI失敗時の対応
1. 失敗ログを確認
2. 簡単な修正（型エラー等）→ 修正してpush（1回だけ試行）
3. 根本的な非互換 → close してissue作成:
   ```bash
   gh pr close <number> --comment "CI失敗: <理由>"
   gh issue create --title "deps: <パッケージ名>の更新が失敗" --label "dependencies" --body "..."
   ```

## ループ停止条件

| 条件 | 動作 |
|------|------|
| Dependabot PRが0件 | 5分待機して再チェック（常駐） |
| ユーザーが「止めて」と言った | 即座に停止 |

## ルール

- Dependabot以外のPRは触らない
- major更新は自動マージしない
- CI失敗の修正は1回だけ試行
- セキュリティアップデートは優先的に処理
