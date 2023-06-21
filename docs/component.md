# コンポーネント 定義ルール

コンポーネントをどのように定義するかのルールを定める。

## 参考リンク

- [アトミックデザイン](https://udemy.benesse.co.jp/design/web-design/atomic-design.html)
- [Container/Presentationalパターン](https://zenn.dev/buyselltech/articles/9460c75b7cd8d1)

## Phoenix.Component - ステートレスなコンポーネント

Presentational Component を指す。

- CoreComponents に定義されているコンポーネントは各所で積極的に使用
- 基本的なパーツ（＝ドメイン知識に依存しないパーツ）は CoreComponents に定義
- その他のパーツは CoreComponents ではなく `***Components` モジュールに定義
  - `***_components.ex` ファイルを配置するディレクトリは CoreComponents と同じ `lib/bright_web/components`

## Phoenix.LiveComponent - ステートフルなコンポーネント

Container Component を指す。

- 状態を持つコンポーネントは扱いや考え方が難しくなるため極力使わず、コンポーネントの親となるLiveViewに状態を持たせる方針
- コンポーネントに状態を持たせる方が明らかに簡潔になる場合は使ってもOK
- `mix phx.gen.live` で生成されるコードの大半を流用する画面（管理機能等）で FormComponent をそのまま使うのもOK
