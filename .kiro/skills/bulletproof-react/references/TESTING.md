# featureベースのテスト戦略

## テストの配置

```
features/{name}/
└── __tests__/
    ├── {ComponentName}.test.tsx    # コンポーネントテスト
    ├── use{HookName}.test.ts       # hookテスト
    └── {apiFunction}.test.ts       # API関数テスト

shared/components/{Name}/
└── {Name}.test.tsx                 # 共有コンポーネントテスト

test/
├── setup.ts                        # グローバルセットアップ
├── mocks/handlers.ts               # MSWハンドラ（API mock）
└── utils.tsx                       # renderWithProviders等
```

## テストの種類と方針

### コンポーネントテスト（Vitest + Testing Library）

```typescript
// features/auth/components/__tests__/LoginForm.test.tsx
import { render, screen, userEvent } from '@/test/utils';
import { LoginForm } from '../LoginForm';

describe('LoginForm', () => {
  it('submits with valid credentials', async () => {
    const onSubmit = vi.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    await userEvent.type(screen.getByLabelText('Email'), 'user@example.com');
    await userEvent.type(screen.getByLabelText('Password'), 'password123');
    await userEvent.click(screen.getByRole('button', { name: 'Login' }));

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'user@example.com',
      password: 'password123',
    });
  });
});
```

### hookテスト

```typescript
// features/todo/hooks/__tests__/useTodos.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { createWrapper } from '@/test/utils';
import { useTodos } from '../useTodos';

describe('useTodos', () => {
  it('fetches todos', async () => {
    const { result } = renderHook(() => useTodos(), { wrapper: createWrapper() });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(3);
  });
});
```

### API関数テスト（MSW）

```typescript
// test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/todos', () =>
    HttpResponse.json([{ id: 1, title: 'Test todo' }])
  ),
];
```

## テストユーティリティ

```typescript
// test/utils.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react';

export function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}

export function renderWithProviders(ui: React.ReactElement) {
  return render(ui, { wrapper: createWrapper() });
}
```

## テストのルール

- 実装の内部構造ではなく**振る舞い**をテスト
- `data-testid` より `role`, `label`, `text` でクエリ
- API呼び出しはMSWでモック（fetch関数を直接モックしない）
- 1テストファイル = 1コンポーネント or 1hook
- featureのテストはfeature内に置く（`__tests__/` ディレクトリ）
