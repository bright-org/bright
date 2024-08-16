defmodule Storybook.BrightGraphComponents.TriangleGraph do
  use PhoenixStorybook.Story, :component

  def function, do: &BrightWeb.BrightGraphComponents.triangle_graph/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          data: %{
            beginner: 35,
            normal: 35,
            skilled: 30
          }
        }
      },
      %Variation{
        id: :data2,
        attributes: %{
          data: %{
            beginner: 50,
            normal: 30,
            skilled: 20
          }
        }
      },
      %Variation{
        id: :data3,
        attributes: %{
          data: %{
            beginner: 20,
            normal: 50,
            skilled: 30
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
      },
      %Variation{
        id: :data5,
        attributes: %{
          data: %{
            beginner: 1000,
            normal: 500,
            skilled: 200
          }
        }
      },
      %Variation{
        id: :data6,
        attributes: %{
          data: %{
            beginner: 1000,
            normal: 100,
            skilled: 50
          }
        }
      },
      %Variation{
        id: :data7,
        attributes: %{
          data: %{
            beginner: 0,
            normal: 0,
            skilled: 0
          }
        }
      },
      %Variation{
        id: :data8_1,
        attributes: %{
          data: %{
            beginner: 1,
            normal: 0,
            skilled: 0
          }
        }
      },
      %Variation{
        id: :data8_2,
        attributes: %{
          data: %{
            beginner: 0,
            normal: 1,
            skilled: 0
          }
        }
      },
      %Variation{
        id: :data8_3,
        attributes: %{
          data: %{
            beginner: 0,
            normal: 0,
            skilled: 1
          }
        }
      },
      %Variation{
        id: :data9_1,
        attributes: %{
          data: %{
            beginner: 0,
            normal: 1,
            skilled: 1
          }
        }
      },
      %Variation{
        id: :data9_2,
        attributes: %{
          data: %{
            beginner: 1,
            normal: 0,
            skilled: 1
          }
        }
      },
      %Variation{
        id: :data9_3,
        attributes: %{
          data: %{
            beginner: 1,
            normal: 1,
            skilled: 0
          }
        }
      }
    ]
  end
end
