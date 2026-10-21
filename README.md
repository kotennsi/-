# 計算室 — 超万能計算機

一般電卓、関数電卓、単位変換などをまとめた日本語のWebアプリです。HTML・CSS・JavaScriptだけで動作し、ビルドや外部ライブラリは必要ありません。

## GitHub Pagesで公開する

1. GitHubで新しいリポジトリを作成します。
2. このフォルダー内のファイルと `icons` フォルダーを、リポジトリの一番上にアップロードします（`outputs/ultra-calculator` フォルダー自体ではなく、その中身です）。
3. リポジトリの **Settings → Pages** を開き、公開元に **Deploy from a branch**、ブランチに **main**、フォルダーに **/(root)** を選んで保存します。
4. Pagesに表示されたURLを開きます。反映まで数分かかることがあります。

GitHub PagesはHTTPSで配信するため、対応ブラウザーではアプリとしてインストールでき、オフライン利用もできます。

## フォルダー構成

```text
.
├── index.html             アプリ本体（画面・計算機能）
├── manifest.webmanifest   インストール用のアプリ情報
├── sw.js                  オフライン利用用のService Worker
├── icon.svg               ブラウザー用アイコン
├── icons/                 インストール用アイコン
├── start-app.bat          Windowsでローカル起動
├── start-app.ps1          ローカルWebサーバー
├── アプリの使い方.txt     Windowsでの起動メモ
├── .nojekyll              GitHub Pagesの公開設定
└── README.md              この説明
```

## Windowsでローカル起動する

`start-app.bat` をダブルクリックします。ブラウザーで開くローカル版とGitHub Pages版は保存場所（オリジン）が異なるため、メモ・履歴・ショートカットは自動では共有されません。

## 更新する

`index.html` やアイコンなどをリポジトリに反映すると、GitHub Pagesが更新されます。Service Workerが以前の画面を表示する場合は、ページを再読み込みしてください。
