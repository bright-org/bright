# Bright インフラ構成管理

[インフラ構成](../docs/infrastructure.md)に従って、Terraformを使ってGoogle Cloudの各種リソースを管理する。

## 事前準備

### ツール

asdfで以下のツールをインストールする（バージョンは [.tool-versions](./.tool-versions) を参照）。

- Terraform
- TFLint

### Terraform Cloud

[Terraform Cloud](https://app.terraform.io/public/signup/account?product_intent=terraform)で、秘匿情報の管理とプロビジョニングの実行を管理する。

1. Terraform Cloudのアカウントを（持っていなければ）作成する
2. `terraform login` を実行し、ローカルからTerraform Cloudにアクセスできるようにする
3. Organizationに自分のアカウントを招待してもらう

### Google Cloud

Google Cloudのプロジェクトに自分のGoogleアカウントを招待してもらう。

## ディレクトリ構成

[クラスメソッド社が公開しているベストプラクティス](https://dev.classmethod.jp/articles/terraform-bset-practice-jp/)に従う。

```bash
.
├── environments
│   ├── dev
│   ├── stg  # TODO: stg環境を構築する際に作成
│   └── prod # TODO: prod環境を構築する際に作成
└── modules
    └── google
        ├── bucket                  # ユーザーがアップロードしたファイルを保存するGCSバケット
        ├── cloud_run_service       # 空のCloud Runサービス（デプロイはCloud Buildで実行）
        ├── db                      # データベース（PostgreSQL）
        ├── managed_service_account # Googleマネージドサービスアカウントへの権限付与
        ├── oidc_github_actions     # GitHub ActionsでGoogle CloudリソースにアクセスできるようにするためのOIDC設定
        ├── secret                  # アプリケーションから参照する秘匿情報
        └── service_account         # ユーザー管理サービスアカウントへの権限付与
```

## 既存環境の変更とプロビジョニング

dev環境を例とする。

1. `environments/dev` 以下のファイルを更新する
2. モジュールが足りなかったり内容が不足している場合、 `modules` 以下のファイルを更新する
3. `terraform plan` を実行し、各種リソースが意図した通りに変更されるか確認する
4. `develop` ブランチに反映すると、自動でプロビジョニングされる

※プロビジョニングのトリガーは環境ごとに異なる
