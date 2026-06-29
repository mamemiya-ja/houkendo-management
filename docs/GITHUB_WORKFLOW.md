# GitHub運用メモ

このプロジェクトはGitで履歴管理します。GitHub Pagesへ公開する場合も、実データの台帳JSONやバックアップJSONはコミットしないでください。

## 初回の流れ

1. ローカルでGitリポジトリを作成します。
2. `index.html`, `app.js`, `styles.css`, `sw.js`, `manifest.webmanifest`, `supabase/`, `docs/`, `README.md` などアプリ本体だけをコミットします。
3. GitHubで新しいリポジトリを作成します。
4. ローカルに `origin` を追加してpushします。
5. GitHub Pagesを有効化します。

## GitHub Pagesで公開する場合

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

Supabase Auth を使う場合、Supabase の Authentication > URL Configuration にこの公開URLを登録してください。

## Supabase設定ファイル

`supabase-config.js` にはブラウザ用の `Project URL` と `anon public key` を入れます。

`anon public key` は公開前提のキーですが、RLSなしで使うと危険です。必ず先に `supabase/schema.sql` をSupabase SQL Editorで実行し、Row Level Securityを有効にしてから公開してください。

## コミットしないもの

- `委託販売管理_台帳.json`
- `*_台帳.json`
- `*バックアップ*.json`
- `*.Zone.Identifier`
- 配布用ZIP
- 個人情報入りバックアップJSON
