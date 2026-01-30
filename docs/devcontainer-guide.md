# DevContainer 開発環境セットアップガイド

## 1. 前提条件

| 項目 | 要件 |
|------|------|
| Docker | Docker Desktop（Windows/Mac）または Docker Engine（Linux） |
| エディタ | VS Code + [Dev Containers 拡張](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) |
| RAM | 12GB 以上 |
| CPU | 4コア以上 |
| ディスク | 30GB 以上の空き容量 |

Docker Desktop を使用する場合は、Settings > Resources からメモリ・CPU の割り当てを確認すること。

## 2. セットアップ手順

### リポジトリのクローン

```bash
git clone <リポジトリURL>
cd saikawa-wbs
```

### DevContainer の起動

1. VS Code でプロジェクトフォルダを開く
2. コマンドパレット（`Ctrl+Shift+P` / `Cmd+Shift+P`）を開く
3. `Dev Containers: Reopen in Container` を選択
4. コンテナのビルドと起動が自動で始まる

初回起動時はコンテナイメージのビルドと依存関係のインストールが行われるため、ネットワーク環境により 10〜30 分程度かかる。2回目以降はキャッシュが効くため数分で起動する。

## 3. 日常の開発フロー

### GDK の操作

```bash
# 起動
gdk start

# 停止
gdk stop

# ログ確認（全サービスのログをリアルタイム表示）
gdk tail
```

### ブラウザアクセス

GDK 起動後、以下の URL でアクセスできる。

```
http://localhost:3000
```

`gdk start` 後、全サービスが起動するまで 1〜2 分かかる場合がある。ブラウザでアクセスできない場合は少し待ってから再試行すること。

## 4. トラブルシューティング

### コンテナの再ビルド

設定変更後やコンテナの状態がおかしい場合に実行する。

1. コマンドパレット（`Ctrl+Shift+P` / `Cmd+Shift+P`）を開く
2. `Dev Containers: Rebuild Container` を選択

キャッシュを使わず完全に再ビルドする場合は `Dev Containers: Rebuild Container Without Cache` を選択する。

### GDK のリセット

GDK が正常に動作しない場合に実行する。

```bash
gdk stop
gdk reconfigure
gdk start
```

### リソース不足時の対処

コンテナが頻繁にクラッシュする、動作が極端に遅い場合はリソース不足の可能性がある。

- **Docker Desktop**: Settings > Resources でメモリを 12GB 以上、CPU を 4コア以上に設定
- **不要なコンテナの停止**: `docker ps` で稼働中のコンテナを確認し、不要なものを `docker stop` で停止
- **ディスク容量の確保**: `docker system prune` で未使用のイメージ・コンテナ・ボリュームが削除される。他プロジェクトのデータも削除対象となるため、実行前に影響範囲を確認すること

## 5. 注意事項

- 初回セットアップにはイメージのダウンロードとビルドで相応の時間がかかる。安定したネットワーク環境で実施すること。
- GDK は多数のサービスを同時に起動するため、推奨スペックを下回る環境では動作が不安定になる可能性がある。
- 開発を終了する際は `gdk stop` でサービスを停止してからコンテナを閉じること。
