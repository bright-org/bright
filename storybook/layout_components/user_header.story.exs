defmodule Storybook.Components.UserHeader do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.LayoutComponents.user_header/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
