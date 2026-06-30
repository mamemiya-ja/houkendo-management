# Supabaseセットアップ手順

このアプリはGitHub PagesからSupabaseへ接続し、ログイン中の1アカウント専用台帳を保存します。各アカウントは、それぞれ自分専用の台帳を使います。

## 1. Project URLとpublishable keyを確認

1. Supabaseの対象プロジェクトを開きます。
2. `Project Settings` > `API` を開きます。
3. `Project URL` と `publishable` keyを控えます。
4. `supabase-config.js` に次の形で設定します。

```js
window.HOUKENDO_SUPABASE = {
  url: "https://YOUR_PROJECT_ID.supabase.co",
  anonKey: "YOUR_SUPABASE_PUBLISHABLE_KEY"
};
```

publishable keyはブラウザに置く前提のキーです。ただし、service role keyやJWT secretは公開リポジトリに置かないでください。

## 2. Authenticationを設定

1. Supabaseの `Authentication` > `URL Configuration` を開きます。
2. `Site URL` にGitHub Pagesの公開URLを設定します。
3. `Redirect URLs` に同じ公開URLを追加します。
4. ローカル確認も行う場合だけ、`http://localhost:8000` など開発用URLを追加します。

## 3. データベースを作成

1. Supabaseの `SQL Editor` を開きます。
2. このリポジトリの [supabase/schema.sql](../supabase/schema.sql) の内容を貼り付けます。
3. `Run` を押して実行します。

作成される主なテーブルは `user_ledgers` だけです。`user_id` がログインユーザーと一致する行だけを読み書きできるよう、Row Level Securityを有効にしています。

過去の共有台帳用スキーマが存在する場合、このSQLは台帳所有者のデータを `user_ledgers` に移した後、旧スキーマを削除します。

## 4. アプリで動作確認

1. GitHub Pagesのアプリを開きます。
2. 左下の `ログイン/同期` を押します。
3. メールアドレスと8文字以上のパスワードで `新規登録` します。
4. 確認メールが届いた場合は、メール内のリンクを開いて登録を完了します。
5. ログイン後、取引先や商品を登録し、画面左下が `クラウド: 保存済` になることを確認します。
6. 別端末や別ブラウザで同じアカウントにログインし、`クラウドから読込` で同じ台帳が表示されることを確認します。

## 5. セキュリティ方針

- `anon` / `publishable` keyは公開される前提ですが、RLSで必ずアクセス制御します。
- `service role` keyはブラウザ、GitHub Pages、GitHubリポジトリに置かないでください。
- SQLを変更した場合は、`user_ledgers` のRLSポリシーが残っていることを確認してください。
- GitHub PagesのURLを変更した場合は、Supabase AuthenticationのURL設定も更新してください。
