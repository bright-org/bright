# Bright

Bright!!

## 環境情報

- Elixir: 1.14 系
- Phoenix: 1.7 系
- Erlang: OTP 26 系
- PostgreSQL: 14 系

## ローカル開発環境構築

### Docker で開発環境を構築する場合 (Mac)

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

- Phoenix app
  - http://localhost:4000/
- Livebook
  - http://localhost:8080/
  - ※保存したデータは livebook ディレクトリに保存されます

#### 停止

```
$ docker compose down
```

### Cloud Storage について

開発環境では[fake-gcs-server](https://github.com/fsouza/fake-gcs-server)が起動します

fake-gcs-server にアップロードされたコンテンツは`http://localhost:4443/{bucket_name}/{file_name}` で参照可能
