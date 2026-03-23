---
name: review
description: Use when the user asks to review code, check changes, review PR, or mentions review, audit, check for bugs
---

# Multi-Perspective Code Review

7視点 + 信頼度スコアリングで厳格レビュー。信頼度80以上の指摘のみ報告。

## 7 Perspectives

1. **Security & Safety** (Critical) — injection, auth bypass, secrets exposure, CSRF, XSS, SQLi, path traversal, insecure deserialization
2. **Business Logic** (Critical) — edge cases, race conditions, state inconsistency, off-by-one, null/undefined handling, intent vs implementation の乖離
3. **Architecture & Design** (Critical) — SOLID原則、レイヤー分離、依存性の方向、関心の分離、適切な抽象化レベル、循環依存
4. **Maintainability** (Important) — naming, abstraction, duplication, 認知的複雑度、マジックナンバー、dead code
5. **Performance** (Important) — N+1クエリ、不要な再レンダリング、メモリリーク、O(n²)ループ、不要なAPI呼び出し、バンドルサイズ影響
6. **Error Handling** (Important) — uncaught exceptions, resource cleanup, retry/fallback戦略、ユーザーへのエラーメッセージ、ログの十分性
7. **Testing & Reliability** (Important) — テストカバレッジの妥当性、テストが実装でなく振る舞いを検証しているか、エッジケースのテスト有無、flaky testリスク

## 深掘りレビュー（必須）

diffを読むだけでは不十分。以下を必ず実行すること。

| チェック項目 | 手順 | 見つかるバグの例 |
|-------------|------|-----------------|
| **変更プロパティ/関数の全呼び出し元追跡** | `grep -rn` で全呼び出し元を確認。振る舞い変更が既存コードに波及しないか検証 | プロパティにモードを追加→全呼び出し元の挙動が変わる |
| **enum/定数の値範囲と境界値** | 新しいenumや定数が使われる箇所で、値範囲外・未定義値でクラッシュしないか確認 | `Enum(value)` が有効範囲外でエラー |
| **データの整合性** | API応答のデータと実際のデータが乖離しないか確認 | プレビューデータと実データが別物 |
| **未使用コード検出** | PR内で定義されたクラス/関数が実際に使われているか確認 | 定義のみで参照ゼロ |
| **文字列 vs 型の一貫性** | enum値を文字列で比較している箇所がないか。型安全でない分岐は潜在バグ | 文字列比較とenum比較の混在 |
| **ランタイムクラッシュの可能性** | 型変換（`int()`, `Enum()`, `[index]`）が失敗しうる入力パターンを洗い出す | ユーザー入力→型変換→500エラー |
| **フロント↔バック整合性** | API変更がある場合、フロントの型定義・呼び出し箇所が追従しているか | レスポンス型が変わったのにフロント未更新 |
| **マイグレーション安全性** | DB変更がある場合、既存データとの互換性・ロールバック可能性を確認 | NOT NULL追加で既存行がエラー |

**これらを省略してLGTMを出すことは禁止。** 表面的なコードスタイルだけ見て通すのはレビューではない。

## 領域別の追加チェック

### フロントエンド変更がある場合
- コンポーネントの責務が単一か（表示とロジックの分離）
- 不要な再レンダリングが発生しないか（useMemo/useCallback の適切な使用）
- アクセシビリティ（aria-label, キーボード操作, コントラスト比）
- レスポンシブ対応（ブレイクポイント、モバイル表示）
- XSS対策（dangerouslySetInnerHTML, ユーザー入力の表示）

### バックエンド変更がある場合
- 入力バリデーション（境界値、型、長さ制限）
- 認証・認可チェックの漏れ
- トランザクション境界の適切さ
- N+1クエリの有無
- エラーレスポンスの一貫性（ステータスコード、メッセージ形式）

### インフラ変更がある場合
- 破壊的変更の有無（リソース削除・再作成）
- セキュリティグループ・IAMポリシーの最小権限
- コスト影響の見積もり
- ロールバック手順の有無

## Confidence Scoring

| Score | Action |
|-------|--------|
| 90-100 | Critical — 必ず報告 |
| 80-89 | Important — 報告 |
| <80 | 報告しない（false positive回避） |

## Output Format

```markdown
## レビュー結果

### 指摘事項

#### [{指摘タイトル}]
- **File:** `{path}:{line}`
- **Category:** {Security/Logic/Architecture/Maintainability/Performance/Error Handling/Testing}
- **Confidence:** {80-100}
- **Evidence:** {何を根拠に問題と判断したか}
- **Suggestion:** {修正案}

### 総評
[良い点を先に述べてから、改善点を述べる]

### Verdict
**APPROVE / REQUEST CHANGES / COMMENT** — {理由}
```
