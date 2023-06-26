defmodule Storybook.GemComponents.Gem do
  use PhoenixStorybook.Story, :component

  @spec function :: (any -> any)
  def function, do: &Elixir.BrightWeb.GemComponents.gem/1

  def variations do
    [
      %Variation{
        id: :skill4,
        attributes: %{
          data: "[90, 80, 75, 60]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]
        }
      },
      %Variation{
        id: :skill5,
        attributes: %{
          data: "[90, 80, 75, 60, 90]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ"]
        }
      },
      %Variation{
        id: :skill6,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill7,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2"]
        }
      },
      %Variation{
        id: :skill8,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3"]
        }
      },
      %Variation{
        id: :skill9,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45, 60]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3", "テスト4"]
        }
      },
      %Variation{
        id: :skill10,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45, 60, 45]",
          labels: [
            "Elixir本体",
            "ライブラリ",
            "環境構築",
            "関連スキル",
            "デバッグ",
            "テスト",
            "テスト2",
            "テスト3",
            "テスト4",
            "テスト6"
          ]
        }
      }
    ]
  end
end
