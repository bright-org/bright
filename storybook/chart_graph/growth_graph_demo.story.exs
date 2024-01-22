defmodule Storybook.ChartComponents.GrowthGraphDemo do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ChartComponents.growth_graph_demo/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            other: [10, 10, 10, 10, 45, 80],
            role: [20, 20, 50, 60, 75, 100],
            myselfNow: 55,
            otherNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.9",
            otherSelected: "2020.12",
            comparedOther: true
          }
        }
      }
    ]
  end
end
