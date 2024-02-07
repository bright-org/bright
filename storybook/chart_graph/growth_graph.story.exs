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
            myselfNow: 55,
            otherNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.9",
            otherSelected: "2020.12",
            comparedOther: true
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
            myselfNow: 55,
            otherNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.6",
            otherSelected: "2020.12",
            comparedOther: true
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
            myselfNow: 55,
            otherNow: 60,
            futureDisplay: true,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            otherSelected: "2020.12",
            comparedOther: true
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
            myselfNow: nil,
            otherNow: nil,
            futureDisplay: false,
            otherFutureDisplay: false,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2021.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2021.12"],
            myselfSelected: "2020.9",
            otherSelected: "2020.9",
            comparedOther: true
          }
        }
      },
      %Variation{
        id: :sample1,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 55, 60],
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            futureDisplay: false
          }
        }
      },
      %Variation{
        id: :sample2,
        attributes: %{
          data: %{
            myself: [nil, 0, 35, 45, 55, 60],
            role: [10, 20, 50, 60, 75, 90],
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            futureDisplay: false
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
            otherFutureDisplay: false,
            labels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            otherLabels: ["2020.12", "2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "2021.9",
            otherSelected: "2011.12",
            comparedOther: true
          }
        }
      },
      %Variation{
        id: :with_progress_first_day_january_1,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 53,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            progress: [53]
          }
        }
      },
      %Variation{
        id: :with_progress_third_day_january_3,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            progress: [53, 55, 60]
          }
        }
      },
      %Variation{
        id: :with_progress_first_3days_on_march,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            progress: progress_first_3days_on_march()
          }
        }
      },
      %Variation{
        id: :with_progress_last_3days_on_march,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 60,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            progress: progress_last_3days_on_march()
          }
        }
      },
      %Variation{
        id: :with_progress_per_5_on_march,
        attributes: %{
          data: %{
            myself: [0, 35, 45, 50, 70],
            myselfNow: 54,
            futureDisplay: true,
            labels: ["2021.3", "2021.6", "2021.9", "2011.12"],
            myselfSelected: "now",
            progress: progress_per_5_on_march()
          }
        }
      }
    ]
  end

  defp progress_first_3days_on_march do
    # # data
    # [
    #   53, 55, 60, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    # ]

    nil_90()
    |> List.replace_at(0, 53)
    |> List.replace_at(1, 55)
    |> List.replace_at(2, 60)
  end

  defp progress_last_3days_on_march do
    # # data
    # [
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
    #   nil, nil, nil, nil, nil, nil, nil, 53, 55, 60
    # ]

    nil_90()
    |> List.replace_at(87, 53)
    |> List.replace_at(88, 55)
    |> List.replace_at(89, 60)
  end

  defp progress_per_5_on_march do
    # # data
    # [
    #   51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
    #   52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
    #   53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
    #   51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
    #   52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
    #   53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, nil,
    #   51.1, nil, nil, nil, nil, 51.6, nil, nil, nil, nil,
    #   52.1, nil, nil, nil, nil, 52.6, nil, nil, nil, nil,
    #   53.1, nil, nil, nil, nil, 53.6, nil, nil, nil, 54.0
    # ]

    # 30日間隔でに上げ下げ
    Enum.reduce(0..2, nil_90(), fn index, acc ->
      acc
      |> List.replace_at(0 + 30 * index, 51.1)
      |> List.replace_at(5 + 30 * index, 51.6)
      |> List.replace_at(10 + 30 * index, 52.1)
      |> List.replace_at(15 + 30 * index, 52.6)
      |> List.replace_at(20 + 30 * index, 53.1)
      |> List.replace_at(25 + 30 * index, 53.6)
    end)
  end

  defp nil_90 do
    Enum.map(1..90, fn _ -> nil end)
  end
end
