# kiro-engineer-teams

Kiro CLI 用の `.kiro/` 設定テンプレート。skills（タスク手順書）と steering（ルール）を収録。

## 構成

```
.kiro/
├── steering/                    # 全会話に適用されるルール
│   └── development-rules.md     # 開発系の汎用ルール
└── skills/                      # 特定タスクの手順書
    ├── brainstorming/           # 設計前のブレスト
    ├── implement/               # 自律実装（調査→実装→PR）
    ├── pr/                      # PR作成
    ├── review/                  # 5視点コードレビュー
    ├── create-issue/            # 詳細issue作成
    ├── merge-pr/                # PR作成→CI確認→マージ
    ├── watch-issues/            # issue監視→自動実装
    ├── watch-review/            # PR監視→自動レビュー→マージ
    ├── watch-main/              # mainブランチ監視→検証
    ├── rebase-prs/              # DIRTY PR自動リベース
    ├── never-idle/              # タスク完了後の自動issue取得
    ├── feature-discovery/       # 競合調査→機能ギャップ分析
    ├── ui-audit/                # UI/レイアウト調査
    └── e2e/                     # E2E検証・バグハント
```

## 使い方

プロジェクトルートに `.kiro/` をコピーして使う。
