defmodule Storybook.ChartComponents.GrowthGraphDemo do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ChartComponents.growth_graph_demo/1

  def variations do
    [
      %Variation{
        id: :demo_at_first_day,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [55]
          }
        }
      },
      %Variation{
        id: :demo_point_2_divided_2_at_second_day,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [51, 55]
          }
        }
      },
      %Variation{
        id: :demo_point_2_divided_10_at_day_10,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [51, nil, nil, 52, nil, 53, nil, nil, nil, 55]
          }
        }
      },
      %Variation{
        id: :demo_point_30_divided_30_at_1_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, 51.9, 52.0,
              52.1, 52.2, 52.3, 52.4, 52.5, 52.6, 52.7, 52.8, 52.9, 53.0,
              53.1, 53.2, 53.3, 53.4, 53.5, 53.6, 53.7, 53.8, 53.9, 55.0,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_8_divided_30_at_1_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, 51.5, nil, nil, nil, 51.9, nil,
              nil, nil, 52.3, nil, nil, nil, 52.7, nil, nil, nil,
              53.1, nil, nil, nil, 53.5, nil, nil, nil, 55.0, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_1_divided_30_at_1_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, 55.0, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_30_divided_60_at_2_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, 51.9, 52.0,
              52.1, 52.2, 52.3, 52.4, 52.5, 52.6, 52.7, 52.8, 52.9, 53.0,
              53.1, 53.2, 53.3, 53.4, 53.5, 53.6, 53.7, 53.8, 53.9, 54.0,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, 55.0, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_30_divided_90_at_3_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 55,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, 51.9, 52.0,
              52.1, 52.2, 52.3, 52.4, 52.5, 52.6, 52.7, 52.8, 52.9, 53.0,
              53.1, 53.2, 53.3, 53.4, 53.5, 53.6, 53.7, 53.8, 53.9, 54.0,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, 55.0, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_30_plus_1_divided_90_at_3_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 57,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, 51.9, 52.0,
              52.1, 52.2, 52.3, 52.4, 52.5, 52.6, 52.7, 52.8, 52.9, 53.0,
              53.1, 53.2, 53.3, 53.4, 53.5, 53.6, 53.7, 53.8, 53.9, 54.0,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, 57.0,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_30_plus_today_divided_90_at_3_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 57,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, 51.2, 51.3, 51.4, 51.5, 51.6, 51.7, 51.8, 51.9, 52.0,
              52.1, 52.2, 52.3, 52.4, 52.5, 52.6, 52.7, 52.8, 52.9, 53.0,
              53.1, 53.2, 53.3, 53.4, 53.5, 53.6, 53.7, 53.8, 53.9, 54.0,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              nil, nil, nil, nil, nil, nil, nil, nil, nil, 57.0,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_30_perday_divided_90_at_3_month_go,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, 51.5, nil, nil, nil, 51.9, nil,
              nil, nil, 52.3, nil, nil, nil, 52.7, nil, nil, nil,
              53.1, nil, nil, nil, 53.5, nil, nil, nil, 53.9, nil,
              nil, nil, nil, 54.3, nil, nil, nil, 54.7, nil, nil,
              nil, 55.1, nil, nil, nil, 55.5, nil, nil, nil, 55.9,
              nil, nil, nil, 56.3, nil, nil, nil, 56.7, nil, nil,
              nil, 57.1, nil, nil, nil, 57.5, nil, nil, nil, 57.9,
              nil, nil, 58.3, nil, nil, nil, 58.7, nil, nil, nil,
              59.1, nil, nil, 59.5, nil, nil, nil, 60.0, nil, nil,
            ]
          }
        }
      },
      %Variation{
        id: :demo_point_2_expanded,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, nil, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", nil, "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [52, 60.0]
          }
        }
      },
      %Variation{
        id: :demo_point_10_expanded,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, nil, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", nil, "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, 52, 50.5, nil, 56, nil, 60, 60
            ],
          }
        }
      },
      %Variation{
        id: :demo_point_30_expanded,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, nil, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", nil, "2011.12"],
            myselfSelected: "now",
            myselfRecentSteps: [
              51.1, nil, nil, nil, 51.5, nil, nil, nil, 51.9, nil,
              nil, nil, 52.3, nil, nil, nil, 52.7, nil, nil, nil,
              53.1, nil, nil, nil, 53.5, nil, nil, nil, 53.9, nil,
              nil, nil, nil, 54.3, nil, nil, nil, 54.7, nil, nil,
              nil, 55.1, nil, nil, nil, 55.5, nil, nil, nil, 55.9,
              nil, nil, nil, 56.3, nil, nil, nil, 56.7, nil, nil,
              nil, 57.1, nil, nil, nil, 57.5, nil, nil, nil, 57.9,
              nil, nil, 58.3, nil, nil, nil, 58.7, nil, nil, nil,
              59.1, nil, nil, 59.5, nil, nil, nil, 60.0, nil, nil,
            ]
          }
        }
      },
      # %Variation{
      #   id: :default_demo,
      #   attributes: %{
      #     data: %{
      #       myself: [nil, 0, 35, 45, 50, 70],
      #       other: [10, 10, 10, 10, 45, 80],
      #       role: [20, 20, 50, 60, 75, 100],
      #       myselfNow: 55,
      #       otherNow: 60,
      #       futureDisplay: true,
      #       labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
      #       otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
      #       myselfSelected: "now",
      #       otherSelected: "now",
      #       comparedOther: true,
      #       myselfRecentSteps: [51, 55],
      #       otherRecentSteps: [45, 60]
      #     }
      #   }
      # }
    ]
  end
end
