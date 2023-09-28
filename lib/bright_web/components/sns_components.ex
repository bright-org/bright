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

  @doc """
  フローティングシェアボタン
  Facebook, Twitter(X) のシェアボタンを画面右上に固定表示する

  ## Examples
      <.floating_share_buttons
        text="成長グラフ"
        full_path="/graphs"
      />
  """
  attr :text, :string, default: ""
  attr :full_path, :string, required: true

  def floating_share_buttons(assigns) do
    assigns = Map.put(assigns, :url, "https://app.bright-fun.org#{assigns.full_path}")

    ~H"""
      <div class="fixed gap-x-2 flex p-2 top-16 right-8">
        <a
          class="p-1 border"
          href={"https://www.facebook.com/share.php?#{URI.encode_query(%{u: @url})}"}
          target="_blank"
          rel="nofollow noopener noreferrer"
        >
          Facebook
        </a>
        <a
          class="p-1 border"
          href={"https://twitter.com/share?#{URI.encode_query(%{text: @text, url: @url})}"}
          target="_blank"
          rel="nofollow noopener noreferrer"
        >
          Twitter(X)
        </a>
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
