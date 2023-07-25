defmodule Storybook.Components.Profile do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ProfileComponents.profile_small/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          user_name: "piacere",
          title: "リードプログラマー",
          icon_file_path: "/images/sample/sample-image.png"
        }
      }
    ]
  end
end
