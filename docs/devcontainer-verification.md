# DevContainer 動作検証手順書

## 概要

本手順書は、DevContainer環境が正しく構築されたことを確認するための検証手順を定義する。
すべての検証は手動実行を想定しており、自動テストは後続フェーズで対応する。

---

## 検証チェックリスト

- [ ] DevContainerが正常に起動する
- [ ] GDKホームディレクトリ（/home/git/gdk）が存在する
- [ ] `gdk doctor` がエラーなく完了する
- [ ] `gdk start` でサービスが起動する
- [ ] PostgreSQLに接続できる
- [ ] Redisに接続できる
- [ ] http://localhost:3000 でGitLabにアクセスできる
- [ ] VS Code拡張が正しくインストールされている

---

## 検証手順

### 1. DevContainerが正常に起動する

**確認方法:**

VS Codeのコマンドパレット（`Ctrl+Shift+P`）から `Dev Containers: Reopen in Container` を実行する。

```
確認ポイント:
- コンテナのビルドがエラーなく完了すること
- VS Codeのターミナルがコンテナ内で開くこと
- 左下のステータスバーに「Dev Container」と表示されること
```

**期待する結果:**

- コンテナが正常にビルド・起動し、VS Codeがコンテナ内の環境に接続される
- ターミナルでコマンド実行が可能な状態になる

---

### 2. GDKホームディレクトリが存在する

**確認コマンド:**

```bash
ls -la /home/git/gdk
```

**期待する結果:**

- `/home/git/gdk` ディレクトリが存在し、GDKの構成ファイル群が配置されている
- 以下のようなファイル・ディレクトリが含まれる:
  - `Procfile`
  - `gitlab/`
  - `gitlab-shell/`
  - `gitaly/`

---

### 3. `gdk doctor` がエラーなく完了する

**確認コマンド:**

```bash
cd /home/git/gdk
gdk doctor
```

**期待する結果:**

- すべてのチェック項目が合格（pass）すること
- `ERROR` や `FAIL` が出力されないこと
- 出力末尾に問題なしを示すメッセージが表示される

**異常時の対処:**

- 警告（warning）は許容するが、エラー（error）が出た場合はメッセージに従い修正する
- よくある問題: ポートの競合、依存パッケージの不足

---

### 4. `gdk start` でサービスが起動する

**確認コマンド:**

```bash
cd /home/git/gdk
gdk start
```

起動後、ステータスを確認する:

```bash
gdk status
```

**期待する結果:**

- 主要サービスがすべて `run` 状態であること
- 以下のサービスが起動していること:
  - `rails-web`
  - `rails-background-jobs`
  - `gitaly`
  - `postgresql`
  - `redis`
  - `webpack`（または`vite`）

**異常時の対処:**

- 特定のサービスが起動しない場合はログを確認する:
  ```bash
  gdk tail <サービス名>
  ```

---

### 5. PostgreSQLに接続できる

**確認コマンド:**

```bash
cd /home/git/gdk
psql -h localhost -d gitlabhq_development -c "SELECT version();"
```

または GDK経由で接続する:

```bash
cd /home/git/gdk
gdk psql -d gitlabhq_development -c "SELECT version();"
```

**期待する結果:**

- PostgreSQLのバージョン情報が表示される
- 接続エラーが発生しないこと
- 出力例:
  ```
                                  version
  --------------------------------------------------------------------------
   PostgreSQL 14.x on x86_64-pc-linux-gnu, compiled by gcc ...
  (1 row)
  ```

---

### 6. Redisに接続できる

**確認コマンド:**

```bash
redis-cli ping
```

または、ソケット経由で接続する場合:

```bash
redis-cli -s /home/git/gdk/redis/redis.socket ping
```

**期待する結果:**

- `PONG` が返却されること
- 出力例:
  ```
  PONG
  ```

---

### 7. http://localhost:3000 でGitLabにアクセスできる

**確認方法:**

ブラウザで http://localhost:3000 にアクセスする。

コマンドラインで確認する場合:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/users/sign_in
```

**期待する結果:**

- ブラウザ: GitLabのログイン画面が表示される
- curl: HTTPステータスコード `200` が返却される
- 初回アクセス時はrootユーザーのパスワード設定画面が表示される場合がある

**補足:**

- 初期管理者アカウント:
  - ユーザー名: `root`
  - 初回アクセス時はパスワード設定画面が表示されるので、任意のパスワードを設定する
- Webpackのコンパイルに時間がかかる場合があるため、初回アクセス時は数分待つ必要がある

---

### 8. VS Code拡張が正しくインストールされている

**確認コマンド:**

VS Codeのターミナルで以下を実行する:

```bash
code --list-extensions
```

**期待する結果:**

`devcontainer.json` の `extensions` に定義した拡張機能がすべてインストールされていること。

確認すべき拡張機能:
- `rebornix.ruby` (Ruby)
- `shopify.ruby-lsp` (Ruby LSP)
- `dbaeumer.vscode-eslint` (ESLint)
- `Vue.volar` (Vue - Volar)
- `editorconfig.editorconfig` (EditorConfig)

**補足:**

- 拡張機能の一覧は `devcontainer.json` の定義内容に依存する
- インストール漏れがある場合は `devcontainer.json` の `extensions` セクションを確認する

---

## 検証結果記録

| # | 検証項目 | 結果 | 確認日 | 確認者 | 備考 |
|---|---------|------|--------|--------|------|
| 1 | DevContainer起動 | - | - | - | |
| 2 | GDKディレクトリ存在 | - | - | - | |
| 3 | gdk doctor | - | - | - | |
| 4 | gdk start | - | - | - | |
| 5 | PostgreSQL接続 | - | - | - | |
| 6 | Redis接続 | - | - | - | |
| 7 | GitLab Webアクセス | - | - | - | |
| 8 | VS Code拡張 | - | - | - | |

---

## トラブルシューティング

### コンテナのビルドが失敗する場合

```bash
# Dockerキャッシュをクリアして再ビルド
docker system prune -f
# VS Codeから「Dev Containers: Rebuild Container」を実行
```

### サービスが起動しない場合

```bash
cd /home/git/gdk
# ログを確認
gdk tail
# 再起動を試行
gdk restart
# 設定を再生成
gdk reconfigure
```

### ポート競合が発生する場合

ホスト側で該当ポートを使用しているプロセスを確認する:

```bash
# ホスト側で実行
lsof -i :3000
lsof -i :5432
lsof -i :6379
```
