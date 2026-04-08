
# コンフリクト解決

ブランチをリベースし、コンフリクトマーカーを手動解決して force-push する。

## 手順

### 1. 準備
```bash
git fetch origin
git checkout <ブランチ名>
```

### 2. リベース開始
```bash
git rebase origin/main
```

### 3. コンフリクト解決
各ファイルについて:
1. ファイル全体を読む
2. `<<<<<<<`, `=======`, `>>>>>>>` マーカーを探す
3. 両方の変更の意図を理解し、正しい結果を書き込む
4. マーカーは一切残さない

```bash
git add <解決したファイル>
git rebase --continue
```

### 4. 解決不能な場合
```bash
git rebase --abort
```
人間にエスカレーション。

### 5. push
```bash
git push --force-with-lease origin <ブランチ名>
```

### 6. 元のブランチに戻る
```bash
git checkout main
```

## ルール

- `--force` ではなく `--force-with-lease` を使う
- コンフリクトマーカーを残したままコミットしない
- 理解せずに片方を丸ごと採用しない
