defmodule Storybook.Components.BrightButtonComponents do
  use PhoenixStorybook.Story, :component

  def function,
    do: &Elixir.BrightWeb.BrightButtonComponents.user_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          icon_file_path: "/images/sample/sample-image.png"
        }
      }
    ]
  end
end
