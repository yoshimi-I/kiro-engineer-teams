# Issue生成（常に実行 — パイプラインへの引き渡し）

INCEPTIONと8エージェントパイプラインの橋渡し。
設計ドキュメントをエージェントが拾えるGitHub issueに変換する。

## ステップ

### 1. 全INCEPTIONアウトプットを読む
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/user-stories/stories.md`（存在する場合）
- `aidlc-docs/inception/architecture/`（存在する場合）

### 2. issueに分解
各issueは:
- 単一のPRで実装可能
- 独立（issue間の依存を最小化）
- テスト可能（明確な受け入れ基準）

### 3. 優先順位付け
1. プロジェクトセットアップ / スキャフォールディング（最初に必須）
2. コアドメインモデル / データベーススキーマ
3. バックエンドAPIエンドポイント
4. フロントエンドページ / コンポーネント
5. 統合（フロントエンド↔バックエンド接続）
6. テスト（E2E、追加の統合テスト）
7. ポリッシュ（UI、エラー処理、エッジケース）
8. ドキュメント

### 4. issueを作成
各issueについて:
```bash
gh issue create \
  --title "feat: <簡潔な説明>" \
  --label "優先度" \
  --label "<P0-critical|P1-high|P2-medium|P3-low>" \
  --body "## 説明
<実装内容>

## 受け入れ基準
- [ ] <テスト可能な条件1>
- [ ] <テスト可能な条件2>

## 技術メモ
<関連するアーキテクチャ決定、ファイルパス、依存関係>

## 参照
- 要件: aidlc-docs/inception/requirements/requirements.md
- アーキテクチャ: aidlc-docs/inception/architecture/architecture.md"
```

### 5. steeringを更新
確定した技術スタックとプロジェクト規約を
`.kiro/steering/development-rules.md`（プロジェクト固有設定セクション）に記入。

### 6. 状態を更新
`aidlc-docs/aidlc-state.md` を更新:
```
- 現在のフェーズ: INCEPTION ✅ → CONSTRUCTION（パイプライン経由）
- 作成issue数: <件数>
```

### 7. ユーザーに指示
`./scripts/start-pipeline.sh` を実行して8エージェントパイプラインを起動するよう伝える。
