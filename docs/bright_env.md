# 環境変数 BRIGHT_ENV による dev / stg / prod などの環境判定

今動作しているアプリケーションの環境は `BRIGHT_ENV` に格納されています。値は以下です。

- "dev"
- "stg"
- "prod"

dev / stg だけ分岐を追加したいなどの場合に有用です。

`Bright.Utils.Env` にユーティリティ関数を定義しており `Bright.Utils.Env.prod?` などで簡単に判定できるようになっています。

なお、仕組み上は "local" や "test" のような値も追加可能ですので、local 環境や test 環境を判定したい場合も拡張は可能です。

(ただし、Elixir では `dev.exs` や `test.exs` があるので基本的には困らないとは思います。)

## BRIGHT_ENV 設定の仕組み

terraform で各環境のプロビジョニングをする際に Secret Manager に固定値をセットし、cloud build でアプリケーションを build する際に Secret Manager から環境変数に設定しています。

詳しくは以下の PR を参照してください。

https://github.com/bright-org/bright/pull/1343
