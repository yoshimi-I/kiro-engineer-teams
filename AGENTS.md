# Kiro Engineer Teams

このリポジトリは8つのKiro CLIを並列で走らせる自動開発パイプラインのテンプレートです。

## 最初にやること

ユーザーが最初のメッセージを送ったら、以下の手順で進めてください：

1. `.kiro/prompts/brainstorming.md` を読み、ブレインストーミングを開始する
2. ユーザーと対話して作りたいアプリケーションの要件・設計を固める
3. 設計が固まったら `.kiro/steering/development-rules.md` の「プロジェクト固有の設定」セクションに技術スタック・ディレクトリ構成・検証コマンドを書き込む
4. `.kiro/prompts/create-issue.md` を読み、設計をissueに分解して `gh issue create` で作成する
5. 全issue作成後、ユーザーに `./scripts/start-pipeline.sh` の実行を案内する

## パイプライン構成

`scripts/start-pipeline.sh` を実行すると、zellijで8エージェントが並列起動します：

| エージェント | 役割 |
|------------|------|
| Impl-1, Impl-2 | issueを取って実装→PR作成 |
| Review | PRを厳格レビュー→マージ |
| Fix-Review | レビュー指摘を修正 |
| Fix-CI | CI失敗を修正 |
| Watch-Main | mainマージ後にE2E検証 |
| E2E-Hunt | Playwright全ページ巡回 |
| Dependabot | 依存更新PR自動処理 |
