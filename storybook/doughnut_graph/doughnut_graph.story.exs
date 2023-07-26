defmodule Storybook.DoughnutGraphComponents.DoughnutGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.DoughnutGraphComponents.doughnut_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: [10, 20, 30]
        }
      },
      %Variation{
        id: :sample1,
        attributes: %{
          data: [30, 20, 10]
        }
      },
      %Variation{
        id: :sample2,
        attributes: %{
          data: [20, 30, 10]
        }
      }
    ]
  end
end
