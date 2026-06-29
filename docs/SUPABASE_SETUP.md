# GitHub Pages + Supabase + PWA セットアップ

この手順では、PCとスマホで同じ委託販売台帳を同期できるようにします。
アプリ本体は GitHub Pages に置き、台帳データは Supabase のデータベースに保存します。

## 費用を抑えるための注意

個人利用、小規模な台帳運用では Supabase の Free プランから始められます。

- Supabaseプロジェクトは Free プランのまま使います。
- クレジットカード登録や有料アドオンは不要です。
- Compute のアップグレード、Pro プラン、追加ストレージは選ばないでください。
- 使用量画面はときどき確認してください。

このアプリは台帳全体を1つのJSONとして保存します。大量の画像を登録する、頻繁に大規模更新する、外部販売用に多数ユーザーへ提供する段階では、テーブル設計やバックアップ方法を見直してください。

## 1. Supabaseプロジェクトを作る

1. [Supabase](https://supabase.com/) で新しいプロジェクトを作成します。
2. Project Settings > API を開き、`Project URL` と `anon public key` を控えます。
3. Authentication > Providers で Email が有効になっていることを確認します。
4. Authentication > URL Configuration で GitHub Pages のURLを `Site URL` と `Redirect URLs` に登録します。

ローカルで確認する場合は、`Redirect URLs` に次も追加します。

```text
http://localhost:8000
http://127.0.0.1:8000
```

## 2. データベースを作る

Supabase の SQL Editor を開き、このリポジトリの `supabase/schema.sql` をすべて貼り付けて実行します。

作成される主なテーブルは次の3つです。

- `workspaces`: 台帳そのもの。参加コードを持ちます。
- `workspace_members`: どのユーザーがどの台帳に参加しているかを管理します。
- `ledgers`: アプリの台帳データをJSONとして保存します。

Row Level Security を有効にしているため、同じ台帳のメンバーだけが台帳データを読み書きできます。

## 3. アプリへSupabase接続先を設定する

`supabase-config.js` にSupabaseの値を入れます。

```js
window.HOUKENDO_SUPABASE = {
  url: "https://xxxxxxxxxxxx.supabase.co",
  anonKey: "eyJ..."
};
```

`anonKey` はブラウザ用の公開キーです。秘密鍵ではありません。ただし公開キーで使う前提なので、必ず `supabase/schema.sql` のRLSを先に設定してください。

## 4. GitHub Pagesへ公開する

GitHub のリポジトリ設定で Pages を有効にします。

- Source: `Deploy from a branch`
- Branch: `main`
- Folder: `/root`

公開URLを開き、左側の `ログイン/同期` からクラウド台帳を使います。

## 5. 最初の利用者の流れ

1. GitHub Pages のURLを開きます。
2. `ログイン/同期` を押します。
3. メールアドレスとパスワードで `新規登録` します。
4. ログイン後、`台帳を作成` を押します。
5. すでにブラウザ内にデータがある場合は、確認画面でクラウドへ保存します。
6. 表示された `参加コード` を共有相手に伝えます。

## 6. 共有相手の参加方法

1. 同じ GitHub Pages のURLを開きます。
2. `ログイン/同期` を押します。
3. 共有相手自身のメールアドレスとパスワードで `新規登録` します。
4. ログイン後、参加コードを入力して `台帳に参加` を押します。
5. 同じクラウド台帳が読み込まれます。

参加コードは台帳に入るための合鍵のようなものです。共有相手以外には渡さないでください。

## 7. スマホでアプリとして使う

iPhone の場合は Safari でURLを開き、共有ボタンから `ホーム画面に追加` を選びます。

Android の場合は Chrome でURLを開き、メニューから `アプリをインストール` または `ホーム画面に追加` を選びます。

PWAとして起動するとブラウザのアドレスバーが減り、通常のWebページよりアプリに近い表示になります。

## 運用上の注意

- 同時編集は避けてください。現状はあとから保存した内容が優先されます。
- 大きな変更前は、アプリ内の `手動バックアップ` でJSONを保存してください。
- 共有相手が入力中のときに自分も同じ台帳を編集する運用は避けてください。
- 外販や複数事業者利用へ広げる場合は、台帳ごとの権限管理、競合検知、バックアップ機能を強化してください。
