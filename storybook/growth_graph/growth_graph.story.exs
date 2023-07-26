defmodule Storybook.GrowthGraphComponents.GrowthGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.GrowthGraphComponents.growth_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 55, 60],
            other: [10, 10, 10, 45, 80],
            role: [20, 50, 60, 75, 90]
          },
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
        }
      },
      %Variation{
        id: :sample1,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 55, 60]
          },
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
        }
      },
      %Variation{
        id: :sample2,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 55, 60],
            role: [20, 50, 60, 75, 90]
          },
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
        }
      },
      %Variation{
        id: :sample3,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 55, 60],
            other: [10, 10, 10, 45, 80]
          },
          labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"]
        }
      }
    ]
  end
end
