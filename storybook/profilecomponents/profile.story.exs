defmodule Storybook.Components.Profile do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ProfileComponents.profile/0

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
