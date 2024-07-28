# 環境変数の反映手順

API キーなどの秘匿性の高い情報を、リポジトリに直接記載することは避ける必要があります。

ではどのようにすべきかというと `config/prod.exs` や `config/runtime.exs` に環境変数経由で記載します。

環境変数は本番の docker イメージのビルド時に Cloud Build 経由で設定されます。 設定内容は [cloudbuild.yaml](../cloudbuild.yaml) に記載されています。

Cloud Build は Secret Manager から値を取得し docker イメージのビルド時に環境変数を設定します。

Secret Manager に設定する、環境変数用の値は、 Terraform によってプロビジョニングされています。

ここでプロビジョニング時に Terraform Cloud を使用しており、Terraform Cloud に設定された variable を使用して Secret Manager に環境変数用の値を設定します。

## 事前知識・準備

以下の説明を理解し、Terraform Cloud の権限などを準備済にしてください。

- [インフラ構成](./infrastructure.md)
- [terraform 周りの説明](../terraform/README.md)

## 手順

### 1. 環境変数用の秘匿情報を取得する

API キーやシークレットなどの秘匿情報を準備します。

この時 dev / stg / prod の 3 環境分用意して設定するのか、それとも prod のみ用意するのか等の考慮が必要です。

最低限 prod 用があれば良いと思いますが、可能であれば dev / stg / prod の 3 環境あるとテストしやすいので、状況に応じて決定しましょう。

### 2. Terraform Cloud の variables に環境変数用の秘匿情報を設定する

各環境の Terraform Cloud に秘匿情報を設定しましょう。

- dev
  - https://app.terraform.io/app/bright-org/workspaces/bright-dev/variables
- stg
  - https://app.terraform.io/app/bright-org/workspaces/bright-stg/variables
- prod
  - https://app.terraform.io/app/bright-org/workspaces/bright-prod/variables

### 3. cloudbuild と terraform のコードを修正する PR を作成する

`terraform` のコードを修正し、各環境ごとに、プロビジョニング時に 2 で追加した variables から Secret Manager に価が設定されるようにします。

また `cloudbuild` の設定を修正し、ビルド時に Secret Manager から取得した値を用いて、コンテナ内で起動したアプリケーション環境に環境変数が設定されるようにします。

具体的には以下の PR を参考にしてください。

https://github.com/bright-org/bright/pull/1010/files

### 4. PR レビュー依頼をし、マージする

レビュー依頼をしてマージします。

マージされると github action 経由で Cloud Build を用いて docker イメージのビルド・デプロイが行われます。

### 5. dev 環境などで変数が反映されたことを確認する

dev / stg 環境に設定した場合は、環境変数がちゃんと設定されたかを何かしらの手段で確認しましょう。

dev /stg 環境に設定していないなど、何かしらの理由で確認が難しい場合は prod 環境での確認でも構いません。

### 6. リリースして prod 環境で確認を行う

確認が取れたら prod 環境にリリースを行います。

リリース後すぐに確認を行い、問題があれば実装を戻してください。

## Tips

### マージ前に terraform のコード修正がうまくいったかを確認したい場合

- [terraform 周りの説明](../terraform/README.md)

を読んで、ローカルの dev 環境用のディレクトリで `terraform plan` を実行することで確認できます。

実行は dev 環境用の Terraform Cloud で実行され、以下のように GUI で結果を確認することができます。

- https://app.terraform.io/app/bright-org/workspaces/bright-dev/runs/run-nVP5xVkoEkraUwzZ

### 確認用に一時的にローカルに環境変数を設定したいとき

一時的に `docker-compose.yml` を書き換えるなどして、ローカルの実行時に環境変数を設定すればよいです。

ちなみに `docker-compose.override.yml` の仕組みを使うと、コミット前に消す必要がなくなり、うっかりコミットするのを防げるので便利です（ `.gitignore` に記載されています）。

## 参考

- [GitHub OAuth 認証の環境変数追加の PR](https://github.com/bright-org/bright/pull/1010)
