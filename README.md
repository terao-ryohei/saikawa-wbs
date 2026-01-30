# saikawa-wbs

## 概要
saikawa-wbs プロジェクトの GitLab GDK 開発環境。

## 前提条件
- Docker / Docker Compose
- VS Code + Dev Containers 拡張機能

## セットアップ
1. VS Code でこのリポジトリを開く
2. コマンドパレット → "Dev Containers: Reopen in Container"
3. postCreateCommand が自動実行される（初回は15-30分）

## GDK 操作
- 起動: `gdk start`
- 停止: `gdk stop`
- 再起動: `gdk restart`
- 状態確認: `gdk status`
- 診断: `gdk doctor`

## 開発用URL
- GitLab: http://localhost:3000
- Vite (HMR): http://localhost:3038

## トラブルシューティング
- `gdk: command not found` → ターミナルを再起動（remoteEnvのPATH反映）
- `zeitwerk LoadError` → `cd /workspace/gdk && bundle install`
- GDKディレクトリエラー → `cd /workspace/gdk` してから実行
