# OneDrive同期の設定手順

このアプリは Microsoft Graph API を使い、OneDrive のアプリ専用フォルダに `委託販売管理_台帳.json` を保存します。

## 重要

OneDrive同期は、HTTPSで公開したURL、または `http://localhost` で開いた場合に使えます。`file://` で `index.html` を直接開いた状態では Microsoft 認証のリダイレクトURIを登録できないため、OneDrive同期は使えません。

## Microsoft側の準備

1. Microsoft Entra 管理センターで「アプリの登録」を作成します。
2. サポートするアカウント種類は、使うOneDriveに合わせて選びます。
   - 個人のOneDriveなら「個人用 Microsoft アカウント」を含む設定にします。
   - 会社/学校のOneDriveなら組織アカウントを含む設定にします。
3. 「シングルページ アプリケーション (SPA)」のリダイレクトURIを追加します。
   - GitHub Pages例: `https://ユーザー名.github.io/リポジトリ名/`
   - ローカル確認例: `http://localhost:8080/`
4. APIアクセス許可に Microsoft Graph の delegated permission `Files.ReadWrite.AppFolder` を追加します。
5. アプリケーションID (client ID) をコピーします。

## アプリ側の設定

1. アプリをHTTPSのURL、またはlocalhostで開きます。
2. `設定` 画面を開きます。
3. `Microsoft アプリケーションID` に client ID を貼り付けます。
4. `OneDrive台帳ファイル名` を確認します。通常は `委託販売管理_台帳.json` のままで構いません。
5. 必要に応じて `保存時にOneDriveへ自動アップロードする` をONにします。
6. 左メニューの `OneDrive接続` を押してMicrosoftアカウントにサインインします。
7. 初回は `OneDriveへ保存` で現在の台帳を作成するか、既存台帳がある場合は `OneDriveから読込` を押します。

## 競合について

PCとスマホで同時に古い画面を開いたまま編集すると、あとから保存した側が競合する場合があります。その場合は先に `OneDriveから読込` で最新状態を取得してください。

## 参考

- Microsoft Graph: driveItem content upload
- Microsoft Graph: driveItem content download
- Microsoft Graph permissions: Files.ReadWrite.AppFolder
- MSAL.js browser authentication
