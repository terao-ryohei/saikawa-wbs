# GitLab FOSS DevContainer Development Environment

gitlab-foss フォーク（terao-ryohei/gitlab-foss）を使った GDK DevContainer 開発環境。

## 前提条件

- Docker Desktop
- VS Code
- [Dev Containers 拡張](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## セットアップ

1. このディレクトリ（`gitlab-foss-dev/`）を取得する
2. VS Code で開く: `code gitlab-foss-dev`
3. コマンドパレットから **"Dev Containers: Reopen in Container"** を実行する

初回は自動で GDK install が実行され、フォーク（terao-ryohei/gitlab-foss）が clone される。
その後 `feature/gantt-charts` ブランチが自動的にチェックアウトされる。
GitLab ソースの手動 clone は不要（`gdk.yml.template` の `gitlab.repo` で指定済み）。

## 使い方

### マルチルートワークスペース（推奨）

devContainer接続後、マルチルートワークスペースを開くとgitlab/gdk/設定ファイルを分離して管理できる。

#### 開き方

1. コマンドパレット（`Ctrl+Shift+P`）→ **File: Open Workspace from File...**
2. `/workspace/saikawa-wbs.code-workspace` を選択

#### フォルダ構成（3層分離）

| ルート | パス | 用途 |
|--------|------|------|
| **gitlab (dev)** | `/workspace/gdk/gitlab` | コード開発・git差分確認 |
| **gdk (infra)** | `/workspace/gdk` | GDK起動・設定管理 |
| **saikawa-wbs (config)** | `/workspace` | devcontainer設定・ワークスペース管理 |

開発（dev）・インフラ（infra）・設定（config）を分離することで、各ルートの役割が明確になり、ファイル検索やgit操作が対象ルート内に閉じる。

各ルートで重複表示を避けるため `.vscode/settings.json` で `files.exclude` を設定済み。

#### ワークスペース設定の詳細

`saikawa-wbs.code-workspace` には以下のVS Code設定が含まれている。

**`git.repositoryScanMaxDepth: 0`**

GDK配下には gitlab, gitaly, gitlab-shell 等、多数のgitリポジトリが存在する。VS Codeはデフォルトでディレクトリを再帰スキャンしてgitリポジトリを検出するため、GDK環境ではスキャンに時間がかかりエディタが重くなる。`0` に設定することで自動スキャンを無効化し、パフォーマンス問題を回避する。

**`git.ignoredRepositories`**

自動スキャンを無効化した上で、さらに以下のリポジトリをVS Codeのgit管理対象から明示的に除外している。

- `/workspace/gdk/gitlab` — gitlab本体（devルートで個別管理）
- `/workspace/gdk/gitaly` — Gitalyストレージ
- `/workspace/gdk/gitlab-shell` — GitLab Shell
- `/workspace/gdk/gitlab-http-router` — HTTPルーター
- `/workspace/gdk/gitlab-topology-service` — トポロジサービス

これにより、ソースツリーパネルやgit操作が意図したリポジトリのみに限定される。

### GDK 操作

```bash
# GDK 起動
gdk start

# GDK 停止
gdk stop

# GDK 再設定
gdk reconfigure

# ブラウザでアクセス
# http://localhost:3000
```

### ガントチャート

- **ダッシュボード**: http://localhost:3000/dashboard/gantt_charts （ログイン後、サイドメニューからもアクセス可）
- **プロジェクト単位**: http://localhost:3000/{namespace}/{project}/-/gantt_charts

### デフォルトログイン

- ユーザー: `root`
- パスワード: `5iveL!fe`（初回ログイン時にパスワード変更を求められる）

## 技術ノート

- **DB/Redis**: GDK 内蔵（UNIX ソケット接続）。外部コンテナは不使用
- **ポート転送**: 3000（Rails）と 3038（Vite）のみ。追加が必要なら `devcontainer.json` の `forwardPorts` に追加
- **データ永続化**: `gdk-data` named volume で GDK データを永続化。DevContainer 再生成時もデータ保持
- **フロントエンド**: Vite を使用（Webpack は無効化済み）

## バージョン情報

| ツール | バージョン |
|--------|-----------|
| Ruby | 3.2.5 / 3.3.10 |
| PostgreSQL | 17 / 18 |
| Redis | 8.x |
| Go | 1.24.5 |
| Node.js | 22.x |

バージョン不整合が発生した場合は `.devcontainer/Dockerfile` を更新すること。
