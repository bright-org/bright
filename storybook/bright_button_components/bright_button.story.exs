defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.BrightButtonComponents.bright_button/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          "ボタン"
        ]
      }
    ]
  end
end
