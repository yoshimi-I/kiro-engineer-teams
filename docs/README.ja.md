<div align="center">

# 🏭 kiro-engineer-teams

**8エージェント並列開発パイプライン**
**[Kiro CLI](https://kiro.dev/docs/cli/) × [zellij](https://zellij.dev/)**

issue → 実装 → レビュー → マージ → E2E検証を全自動化。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Kiro CLI](https://img.shields.io/badge/Kiro_CLI-compatible-purple.svg)](https://kiro.dev/docs/cli/)

[English](../README.md) · **日本語**

</div>

---

## クイックスタート

### A. 新規プロジェクト（ゼロから始める）

**1. テンプレートからプロジェクト作成（git履歴なし）**
```bash
npx degit yoshimi-I/kiro-engineer-teams my-app
cd my-app
```

**2. 前提ツールをインストール**
```bash
./scripts/setup.sh
```

**3. gitを初期化してGitHubリポジトリを作成**
```bash
git init
gh repo create my-app --private --source=. --push
```

**4. 起動（INCEPTION → 8エージェントパイプライン）**
```bash
./scripts/start-pipeline.sh
```

### B. 既存プロジェクトに追加

**1. .kiro/, scripts/, AGENTS.md をコピー**
```bash
npx degit yoshimi-I/kiro-engineer-teams .kiro-tmp
cp -r .kiro-tmp/.kiro .kiro-tmp/scripts .kiro-tmp/AGENTS.md .
rm -rf .kiro-tmp
```

**2. 前提ツールをインストール（インストール済みはスキップ）**
```bash
./scripts/setup.sh
```

**3. 起動**
```bash
./scripts/start-pipeline.sh
```

> 💡 GitHubの **「Use this template」** ボタンから直接リポジトリを作成することもできます。

---

## 🔄 全体フロー

```
./scripts/start-pipeline.sh
│
├── Phase 1: INCEPTION（あなた + AI）
│   ├── 1. ワークスペース検出 — 既存コードをスキャン
│   ├── 2. 要件分析 — 何を作るか明確化
│   ├── 3. ユーザーストーリー — ユーザー行動を定義（必要時）
│   ├── 4. アーキテクチャ設計 — 技術スタック + 構成（必要時）
│   └── 5. Issue生成 — GitHub issueを自動作成
│
└── Phase 2: 8エージェントパイプライン（完全自律）
    ├── Impl-1, Impl-2 → issueを拾って実装 → PR
    ├── Review → 7視点厳格レビュー → マージ
    ├── Fix-Review → レビュー指摘修正 → 再push
    ├── Fix-CI → CI失敗修正 → 再push
    ├── Watch-Main → マージ後E2E検証
    ├── E2E-Hunt → Playwright巡回 → バグissue
    └── Dependabot → 依存更新PR処理
```

Phase 1はあなたの入力が必要です。Phase 2は完全自動 — エージェントはissue/PRが来るまで待機し、検出次第動き始めます。

---

## 🚀 パイプライン起動

```bash
./scripts/start-pipeline.sh
```

<table>
<tr>
<td align="center">🔨<br><b>Impl-1</b><br><sub>issue → 実装 → PR</sub></td>
<td align="center">🚦<br><b>Fix-CI</b><br><sub>CI失敗 → 修正</sub></td>
</tr>
<tr>
<td align="center">🔨<br><b>Impl-2</b><br><sub>issue → 実装 → PR</sub></td>
<td align="center">👀<br><b>Watch-Main</b><br><sub>main監視 → E2E</sub></td>
</tr>
<tr>
<td align="center">🔍<br><b>Review</b><br><sub>PR → レビュー → マージ</sub></td>
<td align="center">🧪<br><b>E2E-Hunt</b><br><sub>Playwright巡回</sub></td>
</tr>
<tr>
<td align="center">🔧<br><b>Fix-Review</b><br><sub>指摘 → 修正 → push</sub></td>
<td align="center">📦<br><b>Dependabot</b><br><sub>依存更新処理</sub></td>
</tr>
</table>

各エージェントはissue/PRの発生を待機し、検出次第動き始めます。

---

## 🏗️ アーキテクチャ

```
GitHub Issue
    │
    ▼
Agent 1,2: /implement ──→ PR作成
                           │
                           ▼
                     Agent 3: /review
                           │
                      ┌────┴────┐
                   🟢 LGTM   🔴 修正必須
                      │         │
                      ▼         ▼
                 マージ    Agent 4: /fix-review-issues
                      │
                      ▼
                 Agent 5: /fix-ci（CI失敗時）
                      │
                      ▼
                 mainにマージ
                      │
                      ▼
                 Agent 6: /watch-main（E2E検証）
                      │
                 バグ発見? → issue作成 → Agent 1,2 が拾う
                                ▲
                 Agent 7: /e2e-bug-hunt（Playwright巡回）

Agent 8: /auto-dependabot（依存更新、別レーン）
```

> 全エージェントは `issue/task.md` を共有して競合を回避します。

---

## 📋 前提条件

| ツール | インストール | 必須 |
|--------|------------|------|
| [Kiro CLI](https://kiro.dev/docs/cli/) | [ダウンロード](https://kiro.dev/downloads/) | ✅ |
| [zellij](https://zellij.dev/) | `brew install zellij` | ✅ |
| [GitHub CLI](https://cli.github.com/) | `brew install gh` → `gh auth login` | ✅ |
| [just](https://just.systems/) | `brew install just` | 任意（GitLab切替用） |

> **Linux**: `brew install` の代わりに各ツールのインストールドキュメントを参照。
> **Windows**: WSL2を使用するか、各ツールのWindowsインストールドキュメントを参照。

---

## 🛡️ 組み込みルール

steering ファイル（`.kiro/steering/development-rules.md`）が全エージェントの全ターンに適用するルール：

| カテゴリ | 主なルール |
|---------|-----------|
| **TDD** | Red → Green → Refactor。テストなしでコードを書かない。 |
| **テスト** | 3層: Unit（関数ごと）+ Integration（APIごと）+ E2E（ユーザーフローごと） |
| **PRゲート** | Unit + Integration + E2E 全通過必須。テスト不足 = マージ不可。 |
| **エラー処理** | 統一APIエラーフォーマット。行動可能なメッセージ。リソースクリーンアップ。 |
| **API設計** | フロント↔バック型定義を常に同期。両端でバリデーション。 |
| **Git** | worktree隔離。Conventional Commits（英語）。squash mergeのみ。 |
| **セキュリティ** | シークレット禁止。入力検証。パラメータ化クエリ。最小権限。 |
| **パフォーマンス** | N+1禁止。ループ内API禁止。不要な再レンダリング防止。 |
| **並列エージェント** | `issue/task.md` 共有状態。作業前に競合検出。 |

---

## 📁 ディレクトリ構成

```
.kiro/
├── steering/development-rules.md  # ルール（毎ターン自動適用）
├── skills/                        # リファレンス（必要時に参照）
│   ├── clean-ddd-hexagonal/       #   DDD + Clean Architecture
│   ├── frontend-design/           #   UI設計ガイド
│   ├── baseline-ui/               #   Tailwind制約
│   ├── fixing-accessibility/      #   アクセシビリティ
│   ├── fixing-metadata/           #   SEO/OGP
│   └── fixing-motion-performance/ #   アニメーション性能
├── prompts/                       # ワークフロー（/name で呼び出し）
│   ├── implement.md               #   issue → 実装 → PRループ
│   ├── review.md                  #   7視点厳格レビュー
│   ├── fix-review-issues.md       #   レビュー指摘修正
│   ├── fix-ci.md                  #   CI失敗修正
│   ├── watch-main.md              #   main監視 → E2E
│   ├── e2e-bug-hunt.md            #   Playwright巡回
│   ├── auto-dependabot.md         #   依存更新PR処理
│   ├── 8-agent-pipeline.md        #   パイプライン構成ガイド
│   └── ...                        #   brainstorming, pr 等
└── agents/default.json            # エージェント設定
scripts/
├── start-pipeline.sh              # 起動スクリプト
├── agent.sh                       # エージェントラッパー
└── pipeline.kdl                   # zellijレイアウト
```

---

## 🔄 Steering / Skills / Prompts の違い

| | Steering | Skills | Prompts |
|---|:---:|:---:|:---:|
| **ロード** | 毎ターン全文 | メタデータのみ → 必要時にフル | `/name` で全文送信 |
| **確実性** | 100% | エージェント判断 | 100% |
| **用途** | ルール・規約 | リファレンス知識 | タスクの手順書 |

---

## 🔧 カスタマイズ

```bash
# 不要なスキルを削除
rm -rf .kiro/skills/clean-ddd-hexagonal

# 不要なプロンプトを削除
rm .kiro/prompts/auto-dependabot.md

# 追加
mkdir .kiro/skills/my-guide       # + SKILL.md（frontmatter必須）
touch .kiro/prompts/my-workflow.md

# 言語切り替え
# /to-japanese — プロンプト・steeringを日本語に
# /to-english  — プロンプト・steeringを英語に
```

**GitLabの場合:**
```bash
just to-gitlab   # gh → glab
just to-github   # 元に戻す
```

---

<div align="center">

[MIT](../LICENSE) © [yoshimi-I](https://github.com/yoshimi-I)

</div>
