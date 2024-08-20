defmodule Bright.SkillEvidences.Markdown do
  @moduledoc """
  学習メモ内容をマークダウン形式として扱ってHTMLに変換するモジュール
  """

  import Phoenix.HTML

  # 変換対象とするタグ
  # `h1`などが使用されないように許可制にしている
  @tags ~w(p pre code a blockquote ul li br)

  @attrs %{
    "a" => ~w(href target),
    "code" => ~w(class)
  }

  def as_html(content) do
    ast =
      case Earmark.Parser.as_ast(content) do
        {:ok, ast, _} ->
          ast

        {:error, ast, _message} ->
          # コードブロック閉じがない等でエラーになるが無視してastのみ返す
          # error時の例
          # {:error, <ast:略>, [{:error, 1, "Fenced Code Block opened with ``` not closed at end of input"}]
          ast
      end

    ast
    |> Earmark.Transform.map_ast(&post_processor/1)
    |> permit()
    |> Earmark.Transform.transform(%Earmark.Options{compact_output: true, escape: false})
  end

  defp permit(ast) do
    Enum.reduce(ast, [], fn elem, acc ->
      acc ++ [_permit(elem)]
    end)
  end

  defp _permit(content) when is_bitstring(content), do: content

  defp _permit({tag, _attrs, [content], _meta}) when tag not in @tags do
    make_safe_string(content)
  end

  defp _permit({"a", attrs, [content], _meta}) when is_bitstring(content) do
    {"a", make_safe_attrs("a", attrs ++ [{"target", "_blank"}]), [content], %{}}
  end

  defp _permit({tag, attrs, [content], _meta}) when is_bitstring(content) do
    {tag, make_safe_attrs(tag, attrs), [make_safe_string(content)], %{}}
  end

  defp _permit({tag, attrs, inner_ast, _meta}) do
    {tag, make_safe_attrs(tag, attrs), permit(inner_ast), %{}}
  end

  defp make_safe_string(str) do
    str |> html_escape() |> safe_to_string()
  end

  defp make_safe_attrs(tag, attrs) do
    permitted_attrs = Map.get(@attrs, tag, [])
    Enum.filter(attrs, fn {attr, _value} -> attr in permitted_attrs end)
  end

  defp post_processor({"p", attrs, [content], meta} = ast) when is_bitstring(content) do
    content
    |> String.split("\n", global: true, trim: true)
    |> case do
      [_single] ->
        # 特に何もしない
        ast

      multi ->
        multi
        |> Enum.intersperse({"br", [], [""], %{}})
        |> then(&{:replace, {"p", attrs, &1, meta}})
    end
  end

  defp post_processor({"p", attrs, list, meta}) when is_list(list) do
    # 下記のように改行で別ブロックがくるケースでの\nをbrに変換している。
    # ["これはてすと：\n", {"code", [{"class", "inline"}], ["test"], %{}}]
    list
    |> Enum.flat_map(fn
      content when is_bitstring(content) ->
        content
        |> String.split("\n")
        |> Enum.intersperse({"br", [], [""], %{}})
        |> Enum.reject(&(&1 == ""))

      tag ->
        [tag]
    end)
    |> then(&{:replace, {"p", attrs, &1, meta}})
  end

  defp post_processor(ast), do: ast
end
