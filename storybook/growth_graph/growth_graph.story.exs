defmodule Storybook.GrowthGraphComponents.GrowthGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.GrowthGraphComponents.growth_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: [[90, 80, 75, 60]],
          labels: ["エンジニア", "マーケター", "デザイナー", "インフラ"],
        }
      }
    ]
  end
end
