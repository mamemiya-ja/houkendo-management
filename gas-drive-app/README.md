# Google Apps Script + Google Drive版

PCとスマホで同じURLを開き、Google Drive上の台帳JSONを共有して使う版です。

## 何が違うか

- OneDrive / Microsoft Entra のアプリ登録は不要です。
- アプリは Google Apps Script のWebアプリとして動きます。
- データは Google Drive の `委託販売管理アプリ` フォルダ内に `委託販売管理_台帳.json` として保存されます。
- PCを常時起動する必要はありません。
- スマホでも同じGoogleアカウントで開けば同じ台帳を使えます。

## ファイル対応

Apps Scriptエディタでは、以下の名前でファイルを作成してください。

| このフォルダのファイル | Apps Script上の種類/名前 |
|---|---|
| `Code.gs` | スクリプト `Code.gs` |
| `Index.html` | HTML `Index` |
| `Styles.html` | HTML `Styles` |
| `Client.html` | HTML `Client` |
| `appsscript.json` | manifest |

## 手動セットアップ

1. [Google Apps Script](https://script.google.com/) を開きます。
2. `新しいプロジェクト` を作成します。
3. プロジェクト名を `委託販売管理` などに変更します。
4. 既存の `コード.gs` に `Code.gs` の内容を貼り付けます。
5. `+` から HTML ファイルを追加し、`Index`, `Styles`, `Client` を作成します。
6. それぞれ、このフォルダの同名HTMLの内容を貼り付けます。
7. 左メニューの `プロジェクトの設定` で `appsscript.json` を表示する設定をONにします。
8. `appsscript.json` の内容を、このフォルダの `appsscript.json` で置き換えます。
9. 保存します。

## Webアプリとしてデプロイ

1. 右上の `デプロイ` -> `新しいデプロイ` を押します。
2. 種類で `ウェブアプリ` を選びます。
3. `実行するユーザー` は `自分` を選びます。
4. `アクセスできるユーザー` は、まずは `自分のみ` を選びます。
5. `デプロイ` を押します。
6. 初回はGoogle Driveアクセスの承認が出るので許可します。
7. 表示されたWebアプリURLをPC/スマホで開きます。

## スマホで使う

スマホ側も同じGoogleアカウントでログインしてWebアプリURLを開きます。ホーム画面に追加しておくとアプリのように起動できます。

## 既存JSONから移行する

1. Apps Script版Webアプリを開きます。
2. `予備データ読込` から既存の `委託販売管理_台帳.json` を読み込みます。
3. 左メニューの `Google Driveへ保存` を押します。

## 注意

- 複数端末で同時編集すると、最後に保存した内容が勝ちます。
- 念のため、定期的に `手動バックアップ` でJSONを保存してください。
- Google Apps Scriptの実行回数やDrive操作にはGoogleの無料枠の制限がありますが、1人用の台帳利用なら通常は十分です。

## 公式ドキュメント

- https://developers.google.com/apps-script/guides/web
- https://developers.google.com/apps-script/guides/html/reference/run
- https://developers.google.com/apps-script/reference/drive/drive-app
