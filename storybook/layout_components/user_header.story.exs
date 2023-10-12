defmodule Storybook.Components.UserHeader do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.LayoutComponents.user_header/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          page_sub_title: "サブタイトル",
          profile: %{
            user_name: "piacere",
            title: "リードプログラマー",
            icon_file_path: "/images/sample/sample-image.png"
          },
          page_title: "タイトル"
        }
      }
    ]
  end
end
