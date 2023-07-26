defmodule Storybook.Components.TimelineBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.TimelineBarComponents.timeline_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"]
        }
      },
      %Variation{
        id: :myself,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          selected_date: "2022.12",
          type: "myself",
          display_now: true
        }
      },
      %Variation{
        id: :myself_select_2023_12,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          selected_date: "2023.12",
          type: "myself",
          display_now: true
        }
      },
      %Variation{
        id: :myself_now,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          selected_date: "now",
          type: "myself",
          display_now: true
        }
      },
      %Variation{
        id: :other,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          selected_date: "2022.12",
          type: "other"
        }
      },
      %Variation{
        id: :other_select_2023_6,
        attributes: %{
          dates: ["2022.12", "2023.3", "2023.6", "2023.9", "2023.12"],
          selected_date: "2023.6",
          type: "other"
        }
      }
    ]
  end
end
