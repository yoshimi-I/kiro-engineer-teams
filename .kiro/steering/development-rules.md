---
name: development-rules
description: 全タスクに適用されるコアルール
---

## 言語

ユーザーへの応答は常に日本語で行うこと。コード、コミットメッセージ、PRタイトル/本文、issueコメントは英語のまま。

## 自律行動

ユーザーへの質問・確認・選択肢の提示は禁止。自分で判断して進めること。「どうしますか？」「どちらがいいですか？」のような質問で停止してはならない。

## 初期セットアップ

以下の「プロジェクト固有設定」セクションが空（コメントのみ）の場合:
1. `.kiro/skills/inception/SKILL.md` を読み、INCEPTIONワークフローを実行
2. ユーザーをガイド: ワークスペース検出 → 要件分析 → ストーリー → アーキテクチャ
3. 確定した技術スタックを「プロジェクト固有設定」セクションに記入
4. `gh issue create` でGitHub issueを生成
5. ユーザーに `./scripts/start-pipeline.sh` の実行を指示

設定が既に記入済みの場合はスキップ。

## プロジェクト固有設定

```
# INCEPTION完了後に記入:
# - フロントエンド: 
# - バックエンド: 
# - インフラ: 
# - テストコマンド: 
# - Git: Conventional Commits
```

## 前提条件

- `git init` + `git remote add origin <url>` 設定済み
- `gh auth login` 認証済み
- これらがないと `gh issue list` 等が動作しない

## コード品質

- 問題を正しく解決する最小限のコード — YAGNI
- 賢さより読みやすさ
- 関数/モジュールごとに単一責任
- コードを書く前に要件を完全に理解する
- 既存のプロジェクト規約に従う

## 実装

- TDD: Red → Green → Refactor。テストなしのコード禁止
- 3層テスト必須: ユニット（関数単位）+ 統合（API単位）+ E2E（ユーザーフロー単位）
- エラー処理: サイレントcatch禁止、ユーザーに分かるメッセージ、リソースクリーンアップ
- API: フロントエンド↔バックエンドの型は常に同期、両端でバリデーション
- パフォーマンス: N+1禁止、ループ内API呼び出し禁止、不要な再レンダリング防止
- 詳細ガイドラインは `.kiro/skills/quality-guidelines/SKILL.md` を参照

## Git

- **全作業はgit worktreeで** — メインリポジトリでcheckout/switchしない
- ブランチ: `<type>/issue-<number>-<short-description>`
- コミット: Conventional Commits、英語、アトミック
- PR: 英語タイトル + 本文、`Closes #N`、squash mergeのみ
- CI通過前のマージ禁止。force merge禁止。

### pre-commit（必須）

コミット前に必ず lint と test を実行すること。CI失敗を未然に防ぐ。

```bash
# コミット前に必ず実行（プロジェクト固有設定のコマンドを使う）
# 例: npm run lint && npm run test
# 例: cargo clippy && cargo test
# 例: ruff check . && pytest
```

- lint/test が通らないコードはコミットしない
- 「push してから CI で確認」は禁止 — ローカルで通してからpush
- CI失敗した場合は、そのPRの作成者（Implエージェント）が自分で修正する

## Issue作成ルール

### 優先度ラベル（全issue必須）

| ラベル | 意味 | 例 |
|-------|------|-----|
| `P0-critical` | ユーザーをブロック or 本番障害 | セキュリティ脆弱性、データ損失 |
| `P1-high` | 重要だがブロックはしない | UXに影響するバグ、バリデーション欠如 |
| `P2-medium` | 早めに対応すべき | リファクタリング、パフォーマンス改善 |
| `P3-low` | あると嬉しい | ドキュメント、軽微なDX改善 |

`gh issue create` には必ず `--label "優先度" --label "<P0-critical|P1-high|P2-medium|P3-low>"` を含めること。Implエージェントは P0→P1→P2→P3 の順で取得する。

### コンフリクト防止

issue作成前に、既存のopen issueと変更対象ファイルの重複を確認:
```bash
gh issue list --state open --json number,title,body --jq '.[].body' | grep -i "<対象ファイルまたはモジュール>"
```

| 状況 | アクション |
|------|-----------|
| 既存issueと重複なし | 独立issueとして作成 |
| 既存issueと重複あり | 本文に `depends-on: #<番号>` を記載し `blocked` ラベルを付与 — 依存先がmergeされるまでImplは着手禁止 |

### 依存関係の本文フォーマット

```markdown
## 依存関係
- depends-on: #<番号>（先にmergeが必要）
```

## セキュリティ

- シークレットのハードコード禁止。入力バリデーション。パラメータ化クエリ。最小権限の原則。

## 並列エージェント

- `issue/task.md` が共有状態ファイル — 作業開始前に必ず読む
- 着手時に「着手中」、PR作成後に「レビュー中」を記録
- 他のエージェントが作業中のファイルは変更しない
- issue/PRコメントは全て英語
- 意思決定は `aidlc-docs/audit.md` にISO 8601タイムスタンプで記録
