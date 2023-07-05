defmodule Storybook.Components.SnsComponents do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.BrightWeb.SnsComponents.sns/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          twitter_url: "https://twitter.com/",
          github_url: "https://www.github.com/",
          facebook_url: "https://www.facebook.com/"
        }
      }
    ]
  end
end
