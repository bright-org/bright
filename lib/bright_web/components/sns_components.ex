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
    ~H"""
    <div class="flex gap-x-6 mr-2 mt-1">
      <.icon_button sns_type="twitter" url={@twitter_url} />
      <.icon_button sns_type="github" url={@github_url} />
      <.icon_button sns_type="facebook" url={@facebook_url} />
    </div>
    """
  end

  attr :url, :string
  attr :sns_type, :string, values: ~w(twitter github facebook)

  defp icon_button(%{url: url} = assigns) when url in ["", nil] do
    ~H"""
    <.icon sns_type={@sns_type} disable={true} />
    """
  end

  defp icon_button(assigns) do
    assigns =
      assigns
      |> assign(:url, "window.open('#{assigns.url}')")

    ~H"""
    <button type="button" onclick={@url} class="flex h-[26px]">
      <.icon sns_type={@sns_type} disable={false} />
    </button>
    """
  end

  attr :disable, :boolean
  attr :sns_type, :string, values: ~w(twitter github facebook)

  defp icon(assigns) do
    assigns =
      assigns
      |> assign(src: "/images/common/#{assigns.sns_type}#{disable_icon_suffix(assigns.disable)}")

    ~H"""
    <img src={@src} class="w-[26px] h-[26px]" />
    """
  end

  defp disable_icon_suffix(true), do: "_gray.svg"
  defp disable_icon_suffix(false), do: ".svg"
end
