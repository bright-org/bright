defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function,
    do: &Elixir.BrightWeb.BrightButtonComponents.bell_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          notification_count: 0
        }
      },
      %Variation{
        id: :notification_count_1,
        attributes: %{
          notification_count: 1
        }
      },
      %Variation{
        id: :notification_count_99,
        attributes: %{
          notification_count: 99
        }
      }
    ]
  end
end
