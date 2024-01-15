defmodule Storybook.ChartComponents.GrowthGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ChartComponents.growth_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            other: [10, 10, 10, 10, 45, 80],
            role: [20, 20, 50, 60, 75, 100],
            now: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.9",
            otherSelected: "2020.12"
          }
        }
      },
      %Variation{
        id: :select_2021_6,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            other: [10, 10, 10, 10, 45, 80],
            role: [20, 20, 50, 60, 75, 100],
            now: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.6",
            otherSelected: "2020.12"
          }
        }
      },
      %Variation{
        id: :select_now,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            other: [10, 10, 10, 10, 45, 80],
            role: [20, 20, 50, 60, 75, 100],
            now: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            otherSelected: "2020.12"
          }
        }
      },
      %Variation{
        id: :futureDisplay_false,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            other: [10, 10, 10, 10, 45, 80],
            role: [20, 20, 50, 60, 75, 100],
            futureDisplay: false,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
          }
        }
      },
      %Variation{
        id: :sample1,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 55, 60],
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
          }
        }
      },
      %Variation{
        id: :sample2,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 55, 60],
            role: [10, 20, 50, 60, 75, 90],
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
          }
        }
      },
      %Variation{
        id: :sample3,
        attributes: %{
          data: %{
            myself: [10, 10, 35, 45, 55, 60],
            other: [10, 10, 10, 10, 45, 80],
            futureDisplay: false,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.9",
            otherSelected: "2011.12"
          }
        }
      }
    ]
  end
end
