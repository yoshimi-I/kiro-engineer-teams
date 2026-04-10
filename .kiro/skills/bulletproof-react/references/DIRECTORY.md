# ディレクトリ構成と命名規則

## 完全なディレクトリ構成例

```
src/
├── app/
│   ├── routes/
│   │   ├── __root.tsx              # ルートレイアウト
│   │   ├── index.tsx               # / (ホーム)
│   │   ├── auth/
│   │   │   ├── login.tsx           # /auth/login
│   │   │   └── register.tsx        # /auth/register
│   │   └── dashboard/
│   │       ├── index.tsx           # /dashboard
│   │       └── settings.tsx        # /dashboard/settings
│   ├── provider.tsx                # 全体Provider
│   └── main.tsx                    # エントリポイント
├── features/
│   ├── auth/
│   │   ├── api/
│   │   │   ├── login.ts            # fetch関数
│   │   │   ├── useLogin.ts         # mutation hook
│   │   │   └── useCurrentUser.ts   # query hook
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuthGuard.ts
│   │   ├── stores/
│   │   │   └── authStore.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   ├── __tests__/
│   │   │   ├── LoginForm.test.tsx
│   │   │   └── useLogin.test.ts
│   │   └── index.ts                # 公開API
│   └── todo/
│       ├── api/
│       ├── components/
│       ├── hooks/
│       ├── types/
│       ├── __tests__/
│       └── index.ts
├── shared/
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   └── Modal/
│   │       ├── Modal.tsx
│   │       └── index.ts
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   └── useMediaQuery.ts
│   ├── lib/
│   │   ├── api.ts                  # axiosインスタンス等
│   │   └── queryClient.ts          # TanStack Query設定
│   ├── types/
│   │   └── api.ts                  # APIレスポンス共通型
│   └── utils/
│       ├── format.ts
│       └── validation.ts
└── test/
    ├── setup.ts                    # テストセットアップ
    ├── mocks/
    │   └── handlers.ts             # MSWハンドラ
    └── utils.tsx                   # renderWithProviders等
```

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| featureディレクトリ | kebab-case | `user-profile/`, `todo/` |
| コンポーネントファイル | PascalCase | `LoginForm.tsx` |
| hookファイル | camelCase, `use`プレフィックス | `useAuth.ts` |
| API fetch関数 | camelCase, 動詞始まり | `getTodos.ts`, `createTodo.ts` |
| API hookファイル | camelCase, `use`プレフィックス | `useTodos.ts`, `useCreateTodo.ts` |
| 型定義ファイル | `index.ts` or 対象名 | `types/index.ts` |
| テストファイル | 対象名 + `.test` | `LoginForm.test.tsx` |
| storeファイル | camelCase + `Store` | `authStore.ts` |

## featureの新規作成チェックリスト

1. `features/{name}/` ディレクトリを作成
2. `index.ts` を作成（最初は空でもよい）
3. 必要なサブディレクトリを作成（全て作る必要はない）
4. 公開するものだけ `index.ts` にexport
5. path aliasが設定されていることを確認（`@/features/{name}`）
