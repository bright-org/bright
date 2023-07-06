defmodule Storybook.Components.Head do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.HeadComponents.head/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
