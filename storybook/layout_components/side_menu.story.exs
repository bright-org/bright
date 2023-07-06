defmodule Storybook.Components.LayoutComponents do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.LayoutComponents.side_menu/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
