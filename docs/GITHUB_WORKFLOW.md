# GitHub運用メモ

このプロジェクトはGitで履歴管理します。GitHubへ置く場合は、実データの台帳JSONをコミットしないでください。

## 初回の流れ

1. ローカルでGitリポジトリを作成します。
2. `index.html`, `app.js`, `styles.css`, `README.md`, `docs/` などアプリ本体だけをコミットします。
3. GitHubで新しいプライベートリポジトリを作成します。
4. ローカルに `origin` を追加してpushします。

## GitHub Pagesで公開する場合

OneDrive同期を使う場合、Microsoft EntraのSPAリダイレクトURIにGitHub PagesのURLを登録してください。

例:

```text
https://ユーザー名.github.io/リポジトリ名/
```

GitHub Pagesで公開したURL自体は外部から見えるため、データ本体はOneDriveのアプリ専用フォルダに置き、リポジトリへ台帳JSONを入れない運用にします。

## コミットしないもの

- `委託販売管理_台帳.json`
- `*.Zone.Identifier`
- 配布用ZIP
- 個人情報入りバックアップJSON
