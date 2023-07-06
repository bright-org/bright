defmodule BrightWeb.SnsComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component

  @doc """
  Renders a Sns

  ## Examples
      <.sns
        twitter_url="https://twitter.com/"
        github_url="https://www.github.com/"
        facebook_url="https://www.facebook.com/"
      />
  """
  attr :twitter_url, :string, default: ""
  attr :facebook_url, :string, default: ""
  attr :github_url, :string, default: ""

  def sns(assigns) do
    assigns =
      assigns
      |> assign(:twitter_url, "window.open('#{assigns.twitter_url}')")
      |> assign(:facebook_url, "window.open('#{assigns.facebook_url}')")
      |> assign(:github_url, "window.open('#{assigns.github_url}')")

    ~H"""
    <div class="flex gap-x-6 mr-2">
      <button type="button" onclick={@twitter_url}>
        <img src="/images/common/twitter.svg" width="26px" />
      </button>
      <button type="button" onclick={@github_url}>
        <img src="/images/common/github.svg" width="26px" />
      </button>
      <button type="button" onclick={@facebook_url}>
        <img src="/images/common/facebook.svg" width="26px" />
      </button>
    </div>
    """
  end
end
