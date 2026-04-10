# Dev Server — 開発サーバー常駐

`just dev` を実行して開発サーバー（フロントエンド + バックエンド）を起動・常駐させる。
他の全エージェント（Watch-Main, E2E-Hunt等）はサーバーが起動済みであることを前提に動作する。

## 起動

```bash
just dev
```

`just dev` が存在しない場合は、プロジェクトの起動方法を自分で判断して起動する:
- `pyproject.toml` があれば: `uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload`
- `package.json` があれば: `pnpm dev` or `npm run dev`

## サーバーが落ちた場合

サーバープロセスが終了した場合は自動で再起動する。

## 禁止事項

- サーバー以外の作業（コード修正、issue作成等）は一切行わない
- サーバーを停止して別のことをしない
