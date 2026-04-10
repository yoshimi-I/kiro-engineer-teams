# Import ルールと ESLint 設定

## importルール一覧

### 許可されるimport

```
app/routes/*  →  features/*/index.ts    ✅ ページからfeatureの公開API
app/routes/*  →  shared/*              ✅ ページから共有コード
features/*/内部  →  同feature内部       ✅ feature内の相互参照
features/*    →  shared/*              ✅ featureから共有コード
shared/*      →  shared/*              ✅ shared内の相互参照
```

### 禁止されるimport

```
features/A/*  →  features/B/components/*  ❌ 別featureの内部を直接import
features/A/*  →  features/B/hooks/*       ❌ 別featureの内部を直接import
shared/*      →  features/*              ❌ sharedがfeatureに依存
features/*    →  app/*                   ❌ featureがappに依存
```

### 条件付き許可

```
features/A/*  →  features/B/index.ts     ⚠️ index.ts経由のみ許可
```

## ESLint設定（eslint-plugin-import / eslint-plugin-boundaries）

```javascript
// .eslintrc.js (eslint-plugin-boundaries)
module.exports = {
  plugins: ['boundaries'],
  settings: {
    'boundaries/elements': [
      { type: 'app', pattern: 'src/app/*' },
      { type: 'features', pattern: 'src/features/*', capture: ['feature'] },
      { type: 'shared', pattern: 'src/shared/*' },
      { type: 'test', pattern: 'src/test/*' },
    ],
  },
  rules: {
    'boundaries/element-types': [
      'error',
      {
        default: 'disallow',
        rules: [
          { from: 'app', allow: ['features', 'shared'] },
          { from: 'features', allow: ['shared'] },
          { from: 'shared', allow: ['shared'] },
          { from: 'test', allow: ['features', 'shared'] },
        ],
      },
    ],
    'boundaries/entry-point': [
      'error',
      {
        default: 'disallow',
        rules: [
          { target: ['features'], allow: 'index.ts' },
          { target: ['shared'], allow: '**' },
        ],
      },
    ],
  },
};
```

## path alias設定

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

使用例:
```typescript
import { useAuth } from '@/features/auth';
import { Button } from '@/shared/components/Button';
```
