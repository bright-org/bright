defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function,
    do: &Elixir.BrightWeb.BrightButtonComponents.stock_candidates_for_employment_button/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
