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
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル"]
        }
      },
      %Variation{
        id: :skill5,
        attributes: %{
          data: "[90, 80, 75, 60, 90]",
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ"]
        }
      },
      %Variation{
        id: :skill6,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45]",
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill7,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60]",
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2"]
        }
      },
      %Variation{
        id: :skill8,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45]",
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3"]
        }
      },
      %Variation{
        id: :skill9,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45, 60]",
          data2: "[]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3", "テスト4"]
        }
      },
      %Variation{
        id: :skill10,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45, 60, 45, 60, 45]",
          data2: "[]",
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
      },
      %Variation{
        id: :skill6_2_1,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45]",
          data2: "[100, 90, 85, 70, 100, 55]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_2_2,
        attributes: %{
          data: "[90, 80, 75, 60, 90, 45]",
          data2: "[80, 70, 65, 50, 80, 35]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_2_3,
        attributes: %{
          data: "[50, 50, 50, 80, 80, 80]",
          data2: "[80, 80, 80, 50, 50, 50]",
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      }
    ]
  end
end
