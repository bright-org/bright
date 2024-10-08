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
          detail:
            "高校・大学と野球部に入っていました。チームで開発を行うような仕事が得意です。メインで使っている言語はJavaで中規模～大規模のシステム開発を受け持っています。最近Elixirを学び始め、Elixirで仕事ができると嬉しいです。",
          icon_file_path: "/images/sample/sample-image.png",
          display_excellent_person: true,
          display_anxious_person: true,
          display_return_to_yourself: true,
          display_stock_candidates_for_employment: true,
          display_adopt: true,
          display_recruitment_coordination: true,
          display_sns: true,
          twitter_url: "https://twitter.com/",
          facebook_url: "https://www.facebook.com/",
          github_url: "https://www.github.com/"
        }
      },
      %Variation{
        id: :is_anonymous,
        attributes: %{
          is_anonymous: true
        }
      }
    ]
  end
end
