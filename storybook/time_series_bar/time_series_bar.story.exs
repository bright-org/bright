defmodule Storybook.Components.TimeSeriesBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TimeSeriesBarComponents.time_series_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]
        }
      },
      %Variation{
        id: :my,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          check_date: "2022.12",
          user_type: "my",
          display_now: true

        }
      },
      %Variation{
        id: :my_select_2023_12,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          check_date: "2023.12",
          user_type: "my",
          display_now: true

        }
      },
      %Variation{
        id: :my_now,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          check_date: "now",
          user_type: "my",
          display_now: true

        }
      },
      %Variation{
        id: :other,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          check_date: "2022.12",
          user_type: "other"
        }
      },
      %Variation{
        id: :other_select_2023_6,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          check_date: "2023.6",
          user_type: "other"
        }
      }
    ]
  end
end
