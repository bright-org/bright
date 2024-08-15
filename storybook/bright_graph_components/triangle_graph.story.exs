defmodule Storybook.BrightGraphComponents.TriangleGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &BrightWeb.BrightGraphComponents.triangle_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            beginner: 33,
            normal: 33,
            skilled: 33
          }
        }
      },
      %Variation{
        id: :data2,
        attributes: %{
          data: %{
            beginner: 50,
            normal: 100,
            skilled: 20
          }
        }
      },
      %Variation{
        id: :data3,
        attributes: %{
          data: %{
            beginner: 20,
            normal: 100,
            skilled: 50
          }
        }
      },
      %Variation{
        id: :data4,
        attributes: %{
          data: %{
            beginner: 100,
            normal: 50,
            skilled: 20
          }
        }
      }
    ]
  end
end
