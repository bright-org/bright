defmodule Storybook.ChartComponents.SkillGem do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ChartComponents.skill_gem/1

  def variations do
    [
      %Variation{
        id: :skill_myself_3,
        attributes: %{
          data: [[60, 70, 80]],
          labels: ["Elixir本体", "ライブラリ", "環境構築"],
          color_theme: "myself"
        }
      },
      %Variation{
        id: :skill_myself_6_2_3,
        attributes: %{
          data: [[60, 70, 80, 60, 60, 60], [50, 50, 50, 50, 50, 50]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"],
          color_theme: "myself"
        }
      },
      %Variation{
        id: :skill4_sm,
        attributes: %{
          data: [[90, 80, 75, 60]],
          labels: ["エンジニア", "マーケター", "デザイナー", "インフラ"],
          size: "sm"
        }
      },
      %Variation{
        id: :skill4,
        attributes: %{
          data: [[90, 80, 75, 60]],
          labels: ["エンジニア", "マーケター", "デザイナー", "インフラ"]
        }
      },
      %Variation{
        id: :skill4_no_link,
        attributes: %{
          data: [[90, 80, 75, 60]],
          labels: ["エンジニア", "マーケター", "デザイナー", "インフラ"],
          display_link: "false"
        }
      },
      %Variation{
        id: :skill5,
        attributes: %{
          data: [[90, 80, 75, 60, 90]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ"]
        }
      },
      %Variation{
        id: :skill6,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill7,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45, 60]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2"]
        }
      },
      %Variation{
        id: :skill8,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45, 60, 45]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3"]
        }
      },
      %Variation{
        id: :skill9,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45, 60, 45, 60]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト", "テスト2", "テスト3", "テスト4"]
        }
      },
      %Variation{
        id: :skill10,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45, 60, 45, 60, 45]],
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
        id: :skill6_2_1_a,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45], [80, 70, 65, 50, 80, 100]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_2_1_b,
        attributes: %{
          data: [[80, 70, 65, 50, 80, 100], [90, 80, 75, 60, 90, 45]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_2_2,
        attributes: %{
          data: [[90, 80, 75, 60, 90, 45], [100, 90, 20, 70, 100, 100]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_2_3,
        attributes: %{
          data: [[50, 50, 50, 80, 80, 80], [80, 80, 80, 50, 50, 50]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :skill6_3,
        attributes: %{
          data: [[0, 0, 0, 0, 0, 0], [80, 80, 80, 50, 50, 50]],
          labels: ["Elixir本体", "ライブラリ", "環境構築", "関連スキル", "デバッグ", "テスト"]
        }
      },
      %Variation{
        id: :do_not_draw_less_than_2_labels_lengt2,
        attributes: %{
          data: [[60, 70]],
          labels: ["Elixir本体", "ライブラリ"],
          color_theme: "myself"
        }
      },
      %Variation{
        id: :do_not_draw_less_than_2_labels_lengt1,
        attributes: %{
          data: [[60]],
          labels: ["Elixir本体"],
          color_theme: "myself"
        }
      },
      %Variation{
        id: :do_not_draw_less_than_2_labels_lengt0,
        attributes: %{
          data: [[]],
          labels: [],
          color_theme: "myself"
        }
      }
    ]
  end
end
