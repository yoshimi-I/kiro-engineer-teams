---
name: development-rules
description: 全コーディングタスクに適用される汎用開発ルール
---

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

## Git

- 明確で説明的なコミットメッセージを書く（Conventional Commits推奨）
- コミットはアトミックに — 1つの論理的変更につき1コミット
- 生成ファイル、シークレット、環境固有の設定はコミットしない
- mainブランチへの直接pushは禁止。必ずPR経由

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

- `issue/task.md` は全エージェント共有の状態管理ファイル
- 実装開始前に必ず task.md を読み、他エージェントとの競合を確認する
- 着手時に「着手中」、PR作成後に「レビュー中」を task.md に記録する
