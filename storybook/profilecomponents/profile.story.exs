defmodule Storybook.Components.Profile do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.ProfileComponents.profile/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          user_name: "piacere",
          title: "リードプログラマー",
          detail: "高校・大学と野球部に入っていました。チームで開発を行うような仕事が得意です。メインで使っている言語はJavaで中規模～大規模のシステム開発を受け持っています。最近Elixirを学び始め、Elixirで仕事ができると嬉しいです。",
          icon_file_path: "/images/sample/sample-image.png"
        }
      }
    ]
  end
end
