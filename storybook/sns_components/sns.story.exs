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
      },
      %Variation{
        id: :twitter_url,
        attributes: %{
          twitter_url: "https://twitter.com/",
          github_url: "",
          facebook_url: ""
        }
      },
      %Variation{
        id: :github_url,
        attributes: %{
          twitter_url: "",
          github_url: "https://www.github.com/",
          facebook_url: ""
        }
      },
      %Variation{
        id: :facebook_url,
        attributes: %{
          twitter_url: "",
          github_url: "",
          facebook_url: "https://www.facebook.com/"
        }
      },
      %Variation{
        id: :all_disable,
        attributes: %{
          twitter_url: "",
          github_url: "",
          facebook_url: ""
        }
      }
    ]
  end
end
