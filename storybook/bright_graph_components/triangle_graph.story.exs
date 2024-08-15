defmodule Storybook.BrightGraphComponents.TriangleGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &BrightWeb.BrightGraphComponents.triangle_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            data: [33, 33, 33]
          }
        }
      },
      %Variation{
        id: :data2,
        attributes: %{
          data: %{
            data: [50, 100, 20]
          }
        }
      },
      %Variation{
        id: :data3,
        attributes: %{
          data: %{
            data: [20, 100, 50]
          }
        }
      },
      %Variation{
        id: :data4,
        attributes: %{
          data: %{
            data: [100, 50, 20]
          }
        }
      }
    ]
  end
end
