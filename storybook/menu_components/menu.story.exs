defmodule Storybook.Components.Menu do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.MenuComponents.menu/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
