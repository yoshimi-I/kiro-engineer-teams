---
name: watch-main
description: mainブランチへのマージを継続監視し、テスト実行→バグ発見時にissueを作成する
---

# mainブランチ監視・検証

mainブランチへのマージをポーリングし、新しいマージを検出したらテスト実行 → バグ発見時はGitHub issueを作成。

## 1サイクルの処理

1. `git fetch origin main` → 状態ファイルと照合
2. 新コミットなし → 「監視継続中。」で終了
3. 新コミットあり → マージされたPR特定 → `git pull origin main`
4. lint + テストを実行（基本的な静的検証）
5. 可能であればブラウザ検証（Playwright等）を実行
6. バグ発見 → `gh issue create --label "bug"` で1バグ=1issue作成
7. 状態ファイル更新

## よくあるミス

- テストだけで済ませる → 可能ならブラウザ操作で実際に確認する
- 全バグを1つのissueにまとめる → 1バグ = 1 issue
