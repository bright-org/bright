defmodule Storybook.DoughnutGraphComponents.DoughnutGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.DoughnutGraphComponents.doughnut_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: [10,20,30]
        }
      }
    ]
  end
end
