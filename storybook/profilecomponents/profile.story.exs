defmodule Storybook.Components.Profile do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ProfileComponents.profile/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          user_name: "piacere"
        }
      }
    ]
  end
end
