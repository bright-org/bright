defmodule Storybook.ChartComponents.DoughnutGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &BrightWeb.BrightGraphComponents.triangle_graph/1

  def variations do
    [
      %Variation{
        id: :default
        # attributes: %{
        #  data: [10, 20, 30]
        # }
      }
    ]
  end
end
