defmodule Storybook.Components.Profile do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ProfileComponents.profile_small/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
