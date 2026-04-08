---
name: development-rules
description: 全コーディングタスクに適用される汎用開発ルール
---

## Initial Setup

If the "Project-specific settings" section below is empty (comments only):
1. Read `.kiro/skills/inception/SKILL.md` and run the INCEPTION workflow
2. Guide the user through: workspace detection → requirements → stories → architecture
3. After design is finalized, write tech stack to the "Project-specific settings" section
4. Generate GitHub issues via `gh issue create`
5. Instruct user to run `./scripts/start-pipeline.sh`

If settings are already filled in, skip this section.

## プロジェクト固有の設定

このセクションにプロジェクトの技術スタック・ディレクトリ構成・規約を記載する。
記載がない場合、エージェントはまずプロジェクト構成を調査してからタスクに着手すること。

```
## ここにプロジェクト固有の情報を記載する
## 例:
# - Frontend: React + Vite + Tailwind CSS (frontend/)
# - Backend: FastAPI + SQLAlchemy (backend/)
# - Infra: Terraform (infra/)
# - パッケージ管理: pnpm (frontend), uv (backend)
# - Lint: ruff (backend), ESLint or Oxlint (frontend)
# - Test: pytest (backend), Vitest (frontend), Playwright E2E
# - Git: Conventional Commits
# - タスクランナー: just / make / npm scripts
#
# 検証コマンド:
# - フロントエンド: cd frontend && pnpm run check && pnpm run build
# - バックエンド: cd backend && uv run ruff check . && uv run pytest
```

## 前提条件（パイプライン起動前に必須）

- `git init` 済みであること
- `git remote add origin <repo-url>` でGitHubリポジトリが紐づいていること
- `gh auth login` でGitHub CLIが認証済みであること
- これらが未設定の場合、`gh issue list` 等のコマンドが動作しない

## コード品質

- 問題を正しく解決するために必要な最小限のコードを書く
- 賢さより読みやすさを優先
- 「念のため」のコードは書かない — YAGNI
- 各関数・モジュールは単一の明確な責務を持つ

## コードを書く前に

- 要件を完全に理解してからコードに触る
- 既存コードのパターンと規約を確認する

## 実装

- プロジェクトの既存規約に従う（命名、ファイル構造、フォーマット）
- エラーは明示的に処理する — 例外を黙って握りつぶさない
- 境界（APIエンドポイント、公開関数）で入力を検証する
- 継承より合成を優先
- 関数は短く、焦点を絞る

### TDD（テスト駆動開発）

全ての実装はTDDで行う:

1. **Red**: 失敗するテストを先に書く
2. **Green**: テストを通す最小限のコードを書く
3. **Refactor**: コードを整理する（テストは通ったまま）

ルール:
- テストなしで実装コードを書かない
- 新機能には必ずユニットテストを書く
- バグ修正には再現テストを先に書く
- エッジケース（null, 空, 境界値, エラー）のテストを含める
- テストは実装の内部構造ではなく振る舞いをテストする
- カバレッジよりも意味のあるテストを優先する

### テスト戦略

3層のテストを必ず用意する:

**Unit Test（単体テスト）**
- 全てのビジネスロジック・ユーティリティ関数に必須
- 外部依存はモック/スタブで隔離
- 1関数につき最低: 正常系1 + 異常系1 + エッジケース1
- フロントエンド: コンポーネントの振る舞いテスト（レンダリング、イベント、状態変化）
- バックエンド: ドメインロジック、サービス層、バリデーション

**Integration Test（結合テスト）**
- API エンドポイントごとに必須
- バックエンド: リクエスト→レスポンスの全体フロー（DB含む）
- フロントエンド: API呼び出し→画面反映のフロー
- WebSocket: 接続→メッセージ送受信→切断
- DB: マイグレーション→CRUD→ロールバック

**E2E Test（エンドツーエンドテスト）**
- 主要ユーザーフローごとに必須（Playwright推奨）
- ページ遷移、フォーム送信、認証フロー
- レスポンシブ（デスクトップ + モバイル375px）
- エラー状態（404、ネットワークエラー、バリデーションエラー）
- 各テストでスクリーンショット撮影 + コンソールエラー収集

### PRマージ前のテスト要件

PRは以下を全て満たさないとマージしない:
- [ ] 新規コードに対応するunit testが存在する
- [ ] API変更がある場合、integration testが更新されている
- [ ] UI変更がある場合、E2Eテストが更新されている
- [ ] 全テストがCIで通過している
- [ ] テストが振る舞いをテストしている（実装詳細ではない）

## エラーハンドリング

- 例外を黙って握りつぶさない — 必ずログ出力 or ユーザー通知
- ユーザー向けエラーメッセージは具体的で行動可能にする（「エラーが発生しました」は禁止）
- API エラーレスポンスは統一フォーマット（status code + error code + message）
- リソース（DB接続、ファイルハンドル、WebSocket）は必ずクリーンアップ
- ネットワークエラーにはリトライ + フォールバックを検討する
- フロントエンド: Error Boundary でクラッシュを防ぐ
- バックエンド: 未処理例外をグローバルハンドラで捕捉してログ出力

## API設計

- フロントエンド↔バックエンドの型定義は常に同期する
- API変更時は必ず両方を同時に更新する（片方だけ変更しない）
- WebSocketメッセージ型もフロント↔バックで一致させる
- RESTful: 適切なHTTPメソッド + ステータスコード
- リクエスト/レスポンスのバリデーションを両端で行う
- 破壊的変更はバージョニングで対応する

## ドキュメント

- 公開API（エンドポイント、関数）にはドキュメントを書く
- 「なぜ」そうしたかをコメントに書く（「何を」しているかはコードで表現）
- README、API仕様、アーキテクチャ図は実装と同期させる
- 複雑なビジネスロジックにはインラインコメントを付ける
- 設定値・環境変数は `.env.example` に全て記載する

## パフォーマンス

- N+1クエリを書かない — 必要なデータは1回のクエリで取得
- ループ内でAPI呼び出し・DBクエリを行わない
- フロントエンド: 不要な再レンダリングを防ぐ（memo, useMemo, useCallback）
- 画像・アセットは適切なサイズ・フォーマットで配信する
- バンドルサイズを意識する — 不要な依存を入れない

## Git

### ブランチ運用
- mainブランチへの直接push・直接コミットは**絶対禁止**
- 全ての変更は git worktree で隔離した環境で行う
- メインリポジトリで `git checkout`/`git switch` によるブランチ切り替えは禁止
- ブランチ名は `<type>/issue-<number>-<short-description>` 形式:
  - `feat/issue-42-add-login`
  - `fix/issue-15-websocket-reconnect`
  - `chore/issue-8-update-deps`
- 1ブランチ = 1 issue = 1 PR

### worktree 運用
- 新しいブランチで作業する場合:
  ```bash
  git worktree add ../<project>-<short-name> -b <branch-name>
  cd ../<project>-<short-name>
  ```
- 作業完了・マージ後は必ずクリーンアップ:
  ```bash
  git worktree remove ../<project>-<short-name>
  ```
- メインリポジトリでの禁止コマンド:
  - `git checkout <branch>` (main以外)
  - `git switch <branch>` (main以外)
  - `git checkout -b` / `git switch -c`
- diff やログの確認はチェックアウト不要:
  ```bash
  git diff origin/main...origin/<branch>
  git log origin/<branch>
  ```

### コミット
- Conventional Commits形式: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- コミットメッセージは英語で書く
- コミットはアトミックに — 1つの論理的変更につき1コミット
- 生成ファイル、シークレット、環境固有の設定はコミットしない

### PR
- PRタイトルはConventional Commits形式（英語）: `feat: add login page (#42)`
- PR本文は英語で書く
- 関連issueを `Closes #42` で紐づける
- PRの説明には変更の概要・動機・テスト結果を含める
- `--no-verify` や `--force` は使わない

### マージ
- squash mergeを使う: `gh pr merge --squash --delete-branch`
- CI全通過が必須。CI失敗中のPRはマージしない
- レビューで🟢 LGTMが出るまでマージしない

## デバッグ

- 修正を試みる前にまずバグを再現する
- 根本原因を追跡する — 症状にパッチを当てない
- 修正が実際に問題を解決したことをエビデンスで検証する

## セキュリティ

- シークレットや認証情報をソースコードにハードコードしない
- 外部入力はすべて検証・サニタイズする
- データベースアクセスにはパラメータ化クエリを使う
- 最小権限の原則に従う

## 並列エージェント作業

### task.md による状態管理
- `issue/task.md` は全エージェント共有の唯一の状態管理ファイル
- 実装開始前に**必ず** task.md を読み、他エージェントとの競合を確認する
- 着手時に「着手中」、PR作成後に「レビュー中」を task.md に記録する
- task.md のヘッダー行は絶対に削除しない

### 競合回避
- 同一ファイルを複数エージェントが同時に変更しない
- 変更対象が重なる場合はスキップして次のタスクへ
- 既にPRが存在するissueは取らない
- 他エージェントが「着手中」のissueは取らない

### コミュニケーション
- issue/PRのコメントは全て英語で書く
- レビュー結果（🔴/🟢）はPRコメントに投稿する
- エスカレーション（3回失敗等）もPRコメントで人間に通知する

## Audit Trail

All design decisions and approvals are recorded in `aidlc-docs/audit.md`.

- Append-only — never overwrite existing entries
- Each entry includes ISO 8601 timestamp, stage name, user input, and AI response
- Record all user approvals and rejections
- Record all issue creation events

Format:
```markdown
## [Stage Name]
**Timestamp**: YYYY-MM-DDTHH:MM:SSZ
**User Input**: "[exact user input]"
**AI Response**: "[action taken]"
**Context**: [stage, decision, or artifact created]
---
```

## Document Structure

INCEPTION phase generates documents in `aidlc-docs/`:

```
aidlc-docs/
├── aidlc-state.md                    # Project state tracking
├── audit.md                          # Decision audit trail
└── inception/
    ├── requirements/
    │   ├── requirements.md           # Functional + non-functional
    │   └── requirements-questions.md # Clarification Q&A
    ├── user-stories/
    │   ├── stories.md                # User stories with acceptance criteria
    │   └── personas.md               # User personas
    └── architecture/
        ├── architecture.md           # Component diagram + responsibilities
        ├── technology-stack.md       # Tech choices with rationale
        └── directory-structure.md    # Project layout
```
