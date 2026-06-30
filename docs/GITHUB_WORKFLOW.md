# GitHub管理メモ

このリポジトリはGitHub Pagesで公開するアプリ本体を管理します。データの正本はSupabaseに保存します。

## 初回公開の流れ

1. `index.html`, `app.js`, `styles.css`, `sw.js`, `manifest.webmanifest`, `supabase/`, `docs/`, `README.md` などアプリ本体をコミットします。
2. GitHubのリポジトリをPublicにします。
3. `main` ブランチへpushします。
4. GitHub Pagesを有効化します。

## GitHub Pages設定

リポジトリ設定の Pages で次のように設定します。

```text
Source: Deploy from a branch
Branch: main
Folder: /root
```

公開URLの例:

```text
https://ユーザー名.github.io/リポジトリ名/
```

Supabase Authを使うため、Supabaseの `Authentication` > `URL Configuration` にこの公開URLを登録してください。

## Supabase設定ファイル

`supabase-config.js` にはブラウザ用の `Project URL` と `publishable key` を入れます。これは公開前提のキーですが、`supabase/schema.sql` のRLSが有効であることが必須です。

絶対にコミットしないもの:

- Supabase service role key
- Supabase JWT secret
- GitHub Personal Access Token
- 個人情報を含む一時データ

## 変更時の確認

- `node --check app.js`
- `node --check sw.js`
- 公開URLでログイン、保存、再読込を確認
- 画面やREADMEに旧運用の文言が残っていないことを確認
