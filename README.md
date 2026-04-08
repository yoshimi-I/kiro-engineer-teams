# kiro-engineer-teams

Kiro CLI 用の `.kiro/` 設定テンプレート。  
プロジェクトにコピーするだけで、8つのKiro CLIを並列で走らせる自動開発パイプラインが動く。

## 8-Agent 並列パイプライン

```
[Agent 1] /implement ──────── issue→実装→PR作成
[Agent 2] /implement ──────── 同上（並列で別issue）
[Agent 3] /review ─────────── open PR→厳格レビュー→マージ
[Agent 4] /fix-review-issues── 🔴指摘→修正→再push
[Agent 5] /fix-ci ─────────── CI失敗→ログ解析→修正→再push
[Agent 6] /watch-main ─────── mainマージ検出→E2E検証→バグissue
[Agent 7] /e2e-bug-hunt ───── Playwright巡回→バグissue
[Agent 8] /auto-dependabot ── 依存更新PR→テスト→マージ/close

共有状態: issue/task.md
```

## Skills と Prompts の違い

| | Skills | Prompts |
|---|--------|---------|
| 呼び出し | エージェントが自動判断 | `/name` で明示的に |
| コンテキスト | メタデータのみ起動時ロード、必要時にフル読み込み | 呼び出し時に全文送信 |
| 向いてるもの | リファレンス、ガイドライン | ワークフロー指示、タスク定義 |

## Skills（6個 — リファレンス）

エージェントが必要時に自動参照する知識ベース。

| スキル | 説明 |
|--------|------|
| `clean-ddd-hexagonal` | DDD + Clean Architecture + Hexagonal パターン |
| `frontend-design` | 高品質フロントエンドUI設計ガイド |
| `baseline-ui` | Tailwindのアニメーション・タイポグラフィ・レイアウト制約 |
| `fixing-accessibility` | アクセシビリティ監査チェックリスト |
| `fixing-metadata` | SEO/OGPメタデータ監査チェックリスト |
| `fixing-motion-performance` | アニメーションパフォーマンス監査 |

## Prompts（21個 — ワークフロー）

`/name` で呼び出すタスク手順書。

### パイプライン中核（8エージェント用）

| プロンプト | 役割 | ポーリング |
|-----------|------|-----------|
| `/implement` | issue→実装→PR作成ループ | 即座に次へ |
| `/review` | open PR→7視点厳格レビュー→マージ | 即座に次へ |
| `/fix-review-issues` | 🔴指摘→修正→再push | 2分 |
| `/fix-ci` | CI失敗→ログ解析→修正→再push | 2分 |
| `/watch-main` | mainマージ検出→E2E検証→バグissue | 2分 |
| `/e2e-bug-hunt` | Playwright全ページ巡回→バグissue | サイクル完了後 |
| `/auto-dependabot` | Dependabot PR→CI確認→マージ/close | 5分 |
| `/8-agent-pipeline` | パイプライン全体の起動ガイド | — |

### 補助プロンプト

| プロンプト | 説明 |
|-----------|------|
| `/brainstorming` | 実装前に要件整理・設計案の提示 |
| `/pr` | PR作成のみ |
| `/merge-pr` | PR作成→CI確認→squash merge |
| `/create-issue` | コード調査済みの詳細issue作成 |
| `/resolve-conflicts` | コンフリクト解決（リベース→force-push） |
| `/rebase-prs` | コンフリクトPRの自動リベース |
| `/addressing-pr-review` | PRレビューコメントへの対応 |
| `/watch-issues` | issueポーリング→自動実装 |
| `/code-patrol` | コードベース巡回→問題issue作成 |
| `/e2e` | ブラウザ操作→スクショ→バグissue |
| `/feature-discovery` | 競合調査→機能ギャップ→issue作成 |
| `/ui-audit` | UI/レイアウト調査→改善issue作成 |

## ディレクトリ構成

```
.kiro/
├── steering/
│   └── development-rules.md         # 全会話に自動適用（毎ターン全文ロード）
├── skills/                           # リファレンス（メタデータのみ起動時ロード）
│   ├── clean-ddd-hexagonal/
│   │   ├── SKILL.md
│   │   └── references/              # 詳細ドキュメント（オンデマンド）
│   ├── frontend-design/SKILL.md
│   ├── baseline-ui/SKILL.md
│   ├── fixing-accessibility/SKILL.md
│   ├── fixing-metadata/SKILL.md
│   └── fixing-motion-performance/SKILL.md
└── prompts/                          # ワークフロー（/name で呼び出し）
    ├── 8-agent-pipeline.md           # パイプライン起動ガイド
    ├── implement.md                  # issue→実装→PRループ
    ├── review.md                     # 7視点厳格レビュー
    ├── fix-review-issues.md          # レビュー指摘自動修正
    ├── fix-ci.md                     # CI失敗自動修正
    ├── watch-main.md                 # mainマージ監視
    ├── e2e-bug-hunt.md               # Playwright巡回バグハント
    ├── auto-dependabot.md            # Dependabot自動処理
    ├── pr.md                         # PR作成
    ├── brainstorming.md
    ├── create-issue.md
    ├── resolve-conflicts.md
    ├── rebase-prs.md
    ├── merge-pr.md
    ├── addressing-pr-review.md
    ├── watch-issues.md
    ├── code-patrol.md
    ├── e2e.md
    ├── feature-discovery.md
    └── ui-audit.md
```

## 使い方

### 1. プロジェクトにコピー

```bash
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git
cp -r kiro-engineer-teams/.kiro /path/to/your-project/
```

### 2. プロジェクト固有の設定を追加

`steering/development-rules.md` の「プロジェクト固有の設定」セクションを埋める。

### 3. 8エージェントを起動

```bash
# 8つのターミナルで
kiro-cli chat → /implement          # x2
kiro-cli chat → /review             # x1
kiro-cli chat → /fix-review-issues  # x1
kiro-cli chat → /fix-ci             # x1
kiro-cli chat → /watch-main         # x1
kiro-cli chat → /e2e-bug-hunt       # x1
kiro-cli chat → /auto-dependabot    # x1
```

### 4. 不要なスキル・プロンプトを削除

```bash
# バックエンドがないプロジェクト
rm -rf .kiro/skills/clean-ddd-hexagonal

# E2Eテストがないプロジェクト
rm .kiro/prompts/e2e-bug-hunt.md
```

## steering / skills / prompts の違い

| | steering | skills | prompts |
|---|---------|--------|---------|
| ロード | `file://`（毎ターン全文） | `skill://`（メタデータのみ） | `/name` で全文送信 |
| 確実性 | 100%読まれる | エージェント判断 | 100%（呼び出し時） |
| コンテキスト消費 | 常時 | 必要時のみ | 呼び出し時のみ |
| 用途 | ルール・規約 | リファレンス知識 | タスクの手順書 |

## GitLab を使う場合

```bash
just to-gitlab   # gh CLI → glab CLI に一括変換
just to-github   # 元に戻す
```
