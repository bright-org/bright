defmodule BrightWeb.BrightCoreComponentsTest do
  alias BrightWeb.BrightCoreComponents

  use Bright.DataCase, async: true

  def get_text(%Phoenix.LiveView.Rendered{} = rendered) do
    rendered
    |> Phoenix.HTML.Safe.to_iodata()
    |> to_string()
  end

  describe "text_to_html_with_link" do
    test "convert texts to links" do
      [
        # 基本全体
        {"test", "<p>test</p>"},
        # 基本リンク
        {"https://a.b/c", ~s(href="https://a.b/c">https://a.b/c</a>)},
        # クエリストリング
        {"https://a.b/c?d=1&e=2", ~s(href="https://a.b/c?d=1&e=2">https://a.b/c?d=1&amp;e=2</a>)},
        # ハッシュアンカー
        {"https://a.b/c#d", ~s(href="https://a.b/c#d">https://a.b/c#d</a>)},
        # 日本語エンコード済み
        {"https://a.b/%E3%81%82", ~s(href="https://a.b/%E3%81%82">https://a.b/%E3%81%82</a>)},
        # 日本語はリンク範囲外
        {"https://a.b/c参照", ~s(href="https://a.b/c">https://a.b/c</a>参照)},
        # タグ混在防止確認
        {"https://a.b/c<p>c</p>", ~s(href="https://a.b/c">https://a.b/c</a>)}
      ]
      |> Enum.each(fn {input, expected} ->
        actual = BrightCoreComponents.text_to_html_with_link(%{text: input}) |> get_text()
        assert actual =~ expected
      end)
    end
  end
end
