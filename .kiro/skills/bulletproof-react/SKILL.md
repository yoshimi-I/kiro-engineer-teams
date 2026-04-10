---
name: bulletproof-react
description: >
  フロントエンドアーキテクチャガイド: Bulletproof Reactのfeatureベースコロケーションパターン。ディレクトリ構成、コンポーネント設計、状態管理、API層の設計・変更、レイヤー違反のレビュー時に使用。トリガー: フロントエンドアーキテクチャ, コロケーション, feature-based, ディレクトリ構成, コンポーネント設計, 状態管理, API層。
---

# Bulletproof React — Feature-Based Colocation

featureごとにコード（コンポーネント、hooks、API、型、テスト）をコロケーションし、変更の影響範囲を局所化するフロントエンドアーキテクチャ。

## 使うべき時（使わないべき時）

| 使うべき時 | スキップすべき時 |
|-----------|----------------|
| 5画面以上のSPA/SSRアプリ | LP1枚、静的サイト |
| 複数人での並行開発 | ソロ開発の小規模アプリ |
| featureが独立して成長する | 全画面が密結合 |
| 長期運用（半年以上） | プロトタイプ、PoC |

## コア原則

1. **featureによるコロケーション** — 技術種別（components/, hooks/）ではなくfeature単位でグループ化
2. **明示的な公開API** — 各featureは `index.ts` で公開するものだけをexport
3. **一方向の依存** — feature間の直接importは禁止。共有は `shared/` 経由
4. **レイヤーの分離** — UI / ロジック / データアクセスを分離

## ディレクトリ構成

```
src/
├── app/                       # アプリケーションのエントリポイント
│   ├── routes/                # ルーティング定義
│   ├── provider.tsx           # 全体のProvider（QueryClient, Theme等）
│   └── main.tsx               # エントリポイント
├── features/                  # featureベースのモジュール
│   └── {feature-name}/
│       ├── api/               # API呼び出し（hooks + fetch関数）
│       ├── components/        # feature固有のUIコンポーネント
│       ├── hooks/             # feature固有のカスタムhooks
│       ├── stores/            # feature固有の状態管理
│       ├── types/             # feature固有の型定義
│       ├── utils/             # feature固有のユーティリティ
│       ├── __tests__/         # feature固有のテスト
│       └── index.ts           # 公開API（これだけが外部からimport可能）
├── shared/                    # feature横断の共有コード
│   ├── components/            # 汎用UIコンポーネント（Button, Modal等）
│   ├── hooks/                 # 汎用hooks（useDebounce等）
│   ├── lib/                   # 外部ライブラリのラッパー（axios, dayjs等）
│   ├── types/                 # 共有型定義
│   └── utils/                 # 共有ユーティリティ
└── test/                      # テストユーティリティ、モック、セットアップ
```

## クイック判断ツリー

### 「このコードはどこに置く？」

```
どこに置く？
├─ 1つのfeatureでしか使わない        → features/{name}/ 内
├─ 2つ以上のfeatureで使う            → shared/ に移動
├─ ルーティング定義                   → app/routes/
├─ 全体Provider                      → app/provider.tsx
└─ テストヘルパー・モック             → test/
```

### 「featureを分割すべきか？」

```
分割すべき？
├─ 独立してデプロイ/テストできる      → 別feature
├─ 別チームが担当する                → 別feature
├─ 常に一緒に変更される              → 同じfeature
└─ 共有状態が多すぎる                → 共有部分をshared/に抽出
```

## import ルール（厳守）

| from → to | 許可 | 例 |
|-----------|------|-----|
| feature → 同feature内 | ✅ | `import { useAuth } from './hooks/useAuth'` |
| feature → shared | ✅ | `import { Button } from '@/shared/components'` |
| feature → 別feature | ❌ | `import { UserCard } from '@/features/user/components'` ← 禁止 |
| feature → 別feature/index | ⚠️ | `import { useUser } from '@/features/user'` ← index.ts経由のみ許可 |
| shared → feature | ❌ | shared は feature に依存してはならない |
| app → feature/index | ✅ | ルーティングからfeatureの公開APIを使用 |

**検出すべき違反:**
- featureが別featureの内部モジュールを直接import
- sharedがfeatureをimport
- index.tsに定義されていないものを外部からimport

## featureの公開API（index.ts）

各featureの `index.ts` は、外部に公開するものだけをre-exportする:

```typescript
// features/auth/index.ts
export { LoginForm } from './components/LoginForm';
export { useAuth } from './hooks/useAuth';
export type { User, AuthState } from './types';
```

内部実装の詳細（内部hooks、ヘルパー関数、内部コンポーネント）はexportしない。

## コンポーネント設計

### コンポーネントの分類

| 種類 | 場所 | 責務 |
|------|------|------|
| Page | app/routes/ | ルーティング + featureコンポーネントの組み合わせ |
| Feature Component | features/{name}/components/ | ビジネスロジックを含むUI |
| Shared Component | shared/components/ | ビジネスロジックを含まない汎用UI |

### ルール
- コンポーネントは1ファイル1コンポーネント
- propsの型は同ファイルまたはfeatureのtypes/に定義
- ビジネスロジックはhooksに抽出、コンポーネントはUIに集中

## 状態管理

```
状態の種類は？
├─ サーバー状態（API data）     → TanStack Query / SWR
├─ フォーム状態                 → React Hook Form / フォームライブラリ
├─ feature内のUI状態            → useState / useReducer
├─ feature横断のグローバル状態  → Zustand / Jotai（shared/stores/）
└─ URL状態                      → URLパラメータ / searchParams
```

**原則:** サーバー状態とクライアント状態を混ぜない。サーバー状態はキャッシュライブラリに任せる。

## API層

各featureの `api/` ディレクトリに配置:

```typescript
// features/todo/api/getTodos.ts
import { api } from '@/shared/lib/api';
import type { Todo } from '../types';

export const getTodos = (): Promise<Todo[]> => api.get('/todos');

// features/todo/api/useTodos.ts
import { useQuery } from '@tanstack/react-query';
import { getTodos } from './getTodos';

export const useTodos = () =>
  useQuery({ queryKey: ['todos'], queryFn: getTodos });
```

- fetch関数とhooksを分離（テスト容易性）
- queryKeyはfeature内で一元管理

## アンチパターン

| アンチパターン | 問題 | 修正 |
|--------------|------|------|
| **技術種別フォルダ** | `components/`, `hooks/` をトップレベルに | feature単位にコロケーション |
| **barrel export地獄** | 全てをre-exportして循環依存 | 必要なものだけindex.tsでexport |
| **feature間の直接import** | 密結合、変更の波及 | index.ts経由 or shared/に抽出 |
| **巨大feature** | 1 featureに20+コンポーネント | サブfeatureに分割 |
| **shared肥大化** | 何でもsharedに入れる | 2つ以上のfeatureで使う時だけ |
| **propsバケツリレー** | 5段以上のprops受け渡し | Context or 状態管理ライブラリ |
| **コンポーネント内ビジネスロジック** | UIとロジックが混在 | カスタムhooksに抽出 |

## 参照ドキュメント

| ファイル | 目的 |
|---------|------|
| [references/DIRECTORY.md](references/DIRECTORY.md) | 詳細なディレクトリ構成と命名規則 |
| [references/IMPORT-RULES.md](references/IMPORT-RULES.md) | importルールとESLint設定 |
| [references/TESTING.md](references/TESTING.md) | featureベースのテスト戦略 |
