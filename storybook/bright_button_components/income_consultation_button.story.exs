defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function,
    do: &Elixir.BrightWeb.BrightButtonComponents.income_consultation_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          skill_panel_id: "test"
        }
      }
    ]
  end
end
