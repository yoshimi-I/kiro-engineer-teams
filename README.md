# kiro-engineer-teams

Kiro CLI 用の `.kiro/` 設定テンプレート。  
プロジェクトにコピーするだけで、AIエージェントに開発ルール・タスク手順を注入できる。

## 何ができるか

| カテゴリ | スキル | 説明 |
|---------|--------|------|
| **設計** | `brainstorming` | 実装前に要件整理・設計案の提示・承認フロー |
| **実装** | `implement` | issue→調査→実装→PR作成を自律的に一気通貫 |
| **PR** | `pr` | PR作成のみ（レビュー・マージはしない） |
| **PR** | `merge-pr` | PR作成→CI確認→squash merge まで一気通貫 |
| **レビュー** | `review` | 7視点+信頼度スコアリングの厳格コードレビュー |
| **Issue** | `create-issue` | コード調査済みの詳細issue作成 |
| **自動化** | `watch-issues` | issueポーリング→自動実装→PR作成 |
| **自動化** | `watch-review` | PRポーリング→自動レビュー→squash merge |
| **自動化** | `watch-main` | mainマージ検出→テスト実行→バグissue作成 |
| **自動化** | `rebase-prs` | コンフリクトPRの自動リベース |
| **自動化** | `never-idle` | タスク完了後に自動で次のissueを取得 |
| **調査** | `feature-discovery` | 競合調査→機能ギャップ分析→issue作成 |
| **調査** | `ui-audit` | UI/レイアウト調査→改善issue作成 |
| **検証** | `e2e` | ブラウザ操作→スクショ目視→バグissue作成 |
| **設計** | `clean-ddd-hexagonal` | DDD + Clean Architecture + Hexagonal パターン |
| **実装** | `frontend-design` | 高品質フロントエンドUI設計 |

## 自動化パイプライン

3つのwatchスキルを並行で動かすと、完全自動の開発サイクルが回る。

```
┌─────────────────────────────────────────────────────────┐
│                    自動サイクル                           │
│                                                         │
│  GitHub Issue ──→ watch-issues ──→ implement ──→ pr     │
│       ▲            (ポーリング)    (調査→実装)  (PR作成)  │
│       │                                          │      │
│       │            watch-review (ポーリング)       │      │
│       │            厳格レビュー → 指摘ゼロ → merge │      │
│       │                                          │      │
│       │            watch-main (ポーリング)         │      │
│       │            テスト実行 → 検証               │      │
│       │                 │                               │
│       └──── バグ発見 → issue作成                         │
└─────────────────────────────────────────────────────────┘
```

## ディレクトリ構成

```
.kiro/
├── steering/                        # 全会話に自動適用されるルール
│   └── development-rules.md         # コード品質・Git・セキュリティの汎用ルール
└── skills/                          # 特定タスクの手順書
    ├── brainstorming/SKILL.md
    ├── implement/SKILL.md
    ├── pr/SKILL.md
    ├── merge-pr/SKILL.md
    ├── review/SKILL.md
    ├── create-issue/SKILL.md
    ├── watch-issues/SKILL.md
    ├── watch-review/SKILL.md
    ├── watch-main/SKILL.md
    ├── rebase-prs/SKILL.md
    ├── never-idle/SKILL.md
    ├── feature-discovery/SKILL.md
    ├── ui-audit/SKILL.md
    ├── e2e/SKILL.md
    ├── clean-ddd-hexagonal/SKILL.md  # + references/
    ├── frontend-design/SKILL.md
    └── find-skills/SKILL.md
```

## 使い方

### 1. プロジェクトにコピー

```bash
# リポジトリをclone
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git

# 自分のプロジェクトに .kiro/ をコピー
cp -r kiro-engineer-teams/.kiro /path/to/your-project/
```

### 2. プロジェクト固有の設定を追加

`steering/development-rules.md` にプロジェクト固有のルールを追記:

```markdown
## プロジェクト固有

- 言語: TypeScript + Python
- Frontend: React + Vite + Tailwind CSS
- Backend: FastAPI + SQLAlchemy
- テスト: `cd frontend && pnpm run check` / `cd backend && uv run pytest`
- Git: Conventional Commits
```

### 3. GitLab を使う場合

```bash
just to-gitlab   # gh CLI → glab CLI に一括変換
just to-github   # 元に戻す
```

## steering と skills の違い

| | steering | skills |
|---|---------|--------|
| 適用タイミング | 全会話に自動注入 | 該当タスク時のみ |
| 役割 | ルール・規約 | タスクの手順書 |
| Claude での対応 | `CLAUDE.md` | `.claude/skills/` |
| 例 | 「mainに直接pushしない」 | 「PRレビューの7視点チェック」 |

## スキル間の依存関係

| 呼び出し元 | 内部で使うスキル |
|-----------|----------------|
| `implement` | `brainstorming`, `frontend-design`, `clean-ddd-hexagonal`, `pr` |
| `watch-issues` | `implement`, `pr` |
| `watch-review` | `review`, `rebase-prs` |
| `watch-main` | （単独） |
| `never-idle` | `implement` |

## カスタマイズ

- スキルの追加: `.kiro/skills/<name>/SKILL.md` を作成
- スキルの無効化: ディレクトリごと削除
- ルールの追加: `.kiro/steering/` に新しい `.md` を追加
