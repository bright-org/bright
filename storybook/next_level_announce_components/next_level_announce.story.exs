defmodule Storybook.Components.NextLevelAnnounce do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.NextLevelAnnounceComponents.next_level_announce/1

  def variations do
    [
      %Variation{
        id: :value39,
        attributes: %{
          value: 39,
          size: 100
        }
      },
      %Variation{
        id: :value59,
        attributes: %{
          value: 59,
          size: 100
        }
      },
      %Variation{
        id: :value99,
        attributes: %{
          value: 99,
          size: 100
        }
      },
      %Variation{
        id: :value100,
        attributes: %{
          value: 100,
          size: 100
        }
      }
    ]
  end
end
