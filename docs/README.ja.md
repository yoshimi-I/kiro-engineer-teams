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

```bash
# テンプレートをクローン
git clone https://github.com/yoshimi-I/kiro-engineer-teams.git my-app
cd my-app

# 自分のリポジトリに切り替え
git remote set-url origin <your-repo-url>
git push -u origin main

# Kiro CLIを起動（ブレストが自動で始まる）
kiro-cli chat
```

> 💡 Kiro起動時に `AGENTS.md` を読み、ブレストが始まります。
> 作りたいものを伝えてください。設計が固まるとissueが自動作成されます。
> `/quit` で抜けた後、パイプラインを起動してください。

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

| ツール | 必須 |
|--------|------|
| [Kiro CLI](https://kiro.dev/docs/cli/) | ✅ |
| [zellij](https://zellij.dev/) | ✅ |
| [GitHub CLI](https://cli.github.com/) | ✅ 認証済み (`gh auth login`) |
| git remote | ✅ 設定済み |

---

## 📁 ディレクトリ構成

```
.kiro/
├── steering/development-rules.md  # ルール（毎ターン自動適用）
├── skills/                        # リファレンス（必要時に参照）
│   ├── clean-ddd-hexagonal/          #   DDD + Clean Architecture
│   ├── frontend-design/              #   UI設計ガイド
│   ├── baseline-ui/                  #   Tailwind制約
│   ├── fixing-accessibility/         #   アクセシビリティ
│   ├── fixing-metadata/              #   SEO/OGP
│   └── fixing-motion-performance/    #   アニメーション性能
├── prompts/                       # ワークフロー（/name で呼び出し）
│   ├── implement.md                  #   issue → 実装 → PRループ
│   ├── review.md                     #   7視点厳格レビュー
│   ├── fix-review-issues.md          #   レビュー指摘修正
│   ├── fix-ci.md                     #   CI失敗修正
│   ├── watch-main.md                 #   main監視 → E2E
│   ├── e2e-bug-hunt.md               #   Playwright巡回
│   ├── auto-dependabot.md            #   依存更新PR処理
│   ├── 8-agent-pipeline.md           #   パイプライン構成ガイド
│   └── ...                           #   brainstorming, pr 等
└── agents/default.json            # エージェント設定
scripts/
├── start-pipeline.sh                 # 起動スクリプト
├── agent.sh                          # エージェントラッパー
└── pipeline.kdl                      # zellijレイアウト
```

---

## 🔄 Steering / Skills / Prompts の違い

| | 📜 Steering | 📚 Skills | ⚡ Prompts |
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
