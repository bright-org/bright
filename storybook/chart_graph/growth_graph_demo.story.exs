defmodule Storybook.ChartComponents.GrowthGraphDemo do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ChartComponents.growth_graph_demo/1

  def variations do
    [
      %Variation{
        id: :demo_first_day_january_1,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 53,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [53]
          }
        }
      },
      %Variation{
        id: :demo_third_day_january_3,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [53, 55, 60]
          }
        }
      },
      %Variation{
        id: :demo_first_3days_march_31,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              53, 55, 60, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            ]
          }
        }
      },
      %Variation{
        id: :demo_last_3days_march_31,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, 53, 55, 60
            ]
          }
        }
      },
      %Variation{
        id: :demo_per_days_march_31,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 54,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, 54.0
            ]
          }
        }
      },
      %Variation{
        id: :demo_per_days_march_31_expanded_double,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, nil, 70],
            myselfNow: 54,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", nil, "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, 54.0
            ]
          }
        }
      },
      %Variation{
        id: :demo_per_days_march_31_expanded_flat,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 54,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
              51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
              52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
              53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, 54.0
            ]
          }
        }
      },
    ]
  end
end
