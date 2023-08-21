defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function,
    do: &Elixir.BrightWeb.BrightButtonComponents.plan_upgrade_button/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
