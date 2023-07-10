# インフラ構成

![インフラ構成図](./images/infrastructure.drawio.svg)

| リソース | 用途 |
| --- | --- |
| Cloud Run | Phoenixアプリケーションを稼働させる |
| Cloud SQL | RDB（PostgreSQL）にデータを保存する |
| Cloud Storage | アップロードされたファイルを保存する |

## 構成管理

[インフラ構成管理](../terraform/README.md)を参照すること。

## Phoenixアプリケーションのデプロイ

TODO: Cloud Buildか何かで自動デプロイ
