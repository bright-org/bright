# Bright

Bright!!

## 環境情報

- Elixir: 1.14 系
- Phoenix: 1.7 系
- Erlang: OTP 26 系
- PostgreSQL: 14 系

## ローカル開発環境構築

### Docker で開発環境を構築する場合 (Mac, Rootless docker)

```
$ make setup # 最初の1回だけでOK
```

### WSL2 などにおいて Docker で開発環境を構築する場合 (Windows, etc)

WSL2 などでは Docker コンテナ内で生成したファイルが root になり、開発上の障害になるので別途 Docker ファイル用意しています

```
$ make setup_for_docker_user # 最初の1回だけでOK
$ make setup # 最初の1回だけでOK
```

### 開発環境の起動と停止方法

#### 起動

```
$ docker compose up -d
```

以下で Phoenix アプリケーションにつながります

http://localhost:4000/


Phoenix Storybook（コンポーネントの確認ができます）
http://localhost:4000/storybook/welcome

開発補助に Livebook も用意しています。起動時に Phoenix アプリケーションに接続されるので、iex 代わりに使ってみてください

※保存した Livebook ファイルは本リポジトリの /livebook ディレクトリ以下に保存されます

なお、アプリケーション開発においては必須ではありません。重いので不要であれば docker-compose.yml の対象行を削除 or コメントアウトするなどしてください

http://localhost:8080/

#### 停止

```
$ docker compose down
```

## 開発中の作法

mix test と mix credo が通過することを確認してください

```
$ docker compose exec web mix test
$ docker compose exec web mix credo
```

Tips: 開発中は mix text.watch を起動しておくとファイルの変更に追従して自動でテストが実行されます

```
$ docker compose exec web mix test.watch
```

## Cloud Storage

開発環境では[fake-gcs-server](https://github.com/fsouza/fake-gcs-server)が起動します

fake-gcs-server にアップロードされたコンテンツは`http://localhost:4443/{bucket_name}/{file_name}` で参照可能
