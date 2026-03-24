---
name: implement
description: Use when the user says "実装して", "これ作って", or assigns a specific feature/bugfix task to implement autonomously
---

# 自律実装スキル

issueまたはユーザー指示に基づき、調査→判断→実装→PR作成まで一気通貫で行う。

## Issue進捗管理

`issue/task.md` で管理。着手中→レビュー中→merge済みの順で更新。

## Issue自動選択ルール

issue番号の指定がない場合:

1. `issue/task.md` を確認し、全ステータスを把握
2. テーブルに記載がないissue = 未着手 → 実装対象候補
3. 候補の中から1つ選び、着手中issueとのコンフリクト判定
4. 問題なければ task.md に `着手中` で追記してから実装開始

### コンフリクト判定

| コンフリクトの程度 | 判定 | 例 |
|-------------------|------|-----|
| なし | OK | 完全に別領域（backend vs frontend等） |
| 軽微 | OK | 同一ファイルだが変更箇所が離れている |
| 中程度〜大 | スキップ | 同一関数・同一コンポーネントを変更する |

### 優先順位

1. バグ（bug ラベル）
2. セキュリティ（security ラベル）
3. コード品質（code-quality ラベル）
4. 機能追加（enhancement ラベル）

## Process

1. **タスク把握**: `gh issue view` + tracker確認（重複防止）
2. **Issue選択**: 上記ルールに従い未着手issueを自動選択（番号指定時はスキップ）
3. **調査**: 関連ファイルを最低3つ読む（変更対象+呼び出し元+型定義）
4. **実装方針決定**: 既存パターンとの一貫性を最優先、最小限の変更
5. **実装**: git worktreeで隔離された作業環境を作成してから実装（下記「領域別の実装ガイド」参照）
6. **検証**: 領域に応じたlint・テストコマンドを実行
7. **コミット&PR**: `/pr` スキルでPR作成、task.mdを`レビュー中`に更新

## 利用するスキル

実装の各フェーズで、該当するスキルを必ず参照すること。

| フェーズ | 参照スキル | 条件 |
|---------|-----------|------|
| 設計判断が必要な場合 | `brainstorming` | 要件が曖昧、複数のアプローチがある場合 |
| フロントエンド実装 | `frontend-design` | UI/コンポーネントの変更がある場合は必ず参照 |
| UI品質チェック | `baseline-ui` | Tailwind CSSプロジェクトでUIコンポーネントを実装する場合 |
| アクセシビリティ | `fixing-accessibility` | インタラクティブ要素、フォーム、ダイアログの追加・変更時 |
| メタデータ | `fixing-metadata` | 新規ページ追加、SEO・OGP対応が必要な場合 |
| アニメーション | `fixing-motion-performance` | アニメーション・トランジションの追加・変更時 |
| バックエンド設計 | `clean-ddd-hexagonal` | ドメインモデル・API設計の変更がある場合 |
| PR作成 | `pr` | 実装完了後 |

## 領域別の実装ガイド

### フロントエンド変更がある場合

1. `frontend-design` スキルを必ず読み、デザイン品質を担保する
2. `baseline-ui` スキルでTailwindのアニメーション・タイポグラフィ・レイアウトのアンチパターンをチェック
3. `fixing-accessibility` スキルでアクセシビリティ（ARIA、キーボード操作、コントラスト）を確認
4. 新規ページの場合は `fixing-metadata` スキルでメタデータ（OGP、title、description）を設定
5. アニメーション追加時は `fixing-motion-performance` スキルでパフォーマンスを確認
6. 既存コンポーネントのパターン（命名、ディレクトリ構造、状態管理）を確認
3. 検証コマンド例:
   ```bash
   cd frontend && pnpm run check    # lint + typecheck
   cd frontend && pnpm run build    # ビルド確認
   ```
4. UI変更がある場合はスクリーンショットをPRに添付

### バックエンド変更がある場合

1. `clean-ddd-hexagonal` スキルの原則（SOLID, レイヤー分離, 関心の分離）に沿っているか確認
2. 既存のAPI・モデル・サービスのパターンを確認
3. 検証コマンド例:
   ```bash
   cd backend && uv run ruff check . && uv run pytest   # Python
   cd backend && go test ./...                           # Go
   cd backend && cargo test                              # Rust
   ```
4. API変更がある場合はリクエスト/レスポンスの型定義も更新

### フルスタック変更がある場合

1. バックエンドのAPI変更 → フロントエンドの型定義・API呼び出しも更新
2. 両方の検証コマンドを実行
3. フロントエンド↔バックエンドの整合性を確認（型の一致、エンドポイントのパス等）

### インフラ変更がある場合

1. `terraform plan` で差分を確認してからapply
2. 既存リソースへの影響範囲を把握
3. 破壊的変更がないか確認

## 連続実装ルール

1 issue = 1サブエージェントでコンテキストをクリーンに保つ。

- メインセッションはオーケストレーターとして、issue選択→サブエージェント起動→完了確認→次のissue選択を繰り返す
- 各issueの実装はサブエージェントに委任する
- サブエージェント完了後、メインセッションで task.md を更新し、次のissueを選択

## Common Mistakes

- tracker確認せずに実装開始 → 重複作業の原因
- 調査せずに実装 → 最低3ファイルは読む
- mainで直接作業 → 必ずgit worktreeで隔離環境を作る
- フロントエンド実装で `frontend-design` スキルを無視 → デザイン品質が低下
- バックエンド実装でレイヤー分離を無視 → 保守性が低下
- フルスタック変更でフロント↔バックの型不整合 → ランタイムエラーの原因
