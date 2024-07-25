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
    <div class="flex gap-x-4 lg:gap-x-6 mr-2 mt-1">
      <.icon_button sns_type="twitter" url={@twitter_url} />
      <.icon_button sns_type="github" url={@github_url} />
      <.icon_button sns_type="facebook" url={@facebook_url} />
    </div>
    """
  end

  @doc """
  SNSシェアボタングループ

  ## Examples
      <.sns_share_button_group share_graph_url="https://bright-fun.org" />
  """
  attr :id, :string, default: "share-button-group"
  attr :share_graph_url, :string, required: true

  def sns_share_button_group(assigns) do
    assigns =
      assigns
      |> Map.put(:twitter_text, """
      \"#{assigns.skill_panel}\"スキルパネルをシェアしました！あなたも成長パネルを作成してみませんか？
      #bright_skill
      """)

    ~H"""
      <div
        id={@id}
        class="flex gap-2"
      >
        <.twitter_share_button id={"#{@id}-twitter"} url={@share_graph_url} text={@twitter_text}/>
        <.facebook_share_button id={"#{@id}-facebook"} url={@share_graph_url}/>
      </div>
    """
  end

  defp twitter_share_button(assigns) do
    ~H"""
      <a
        id={@id}
        href={"https://x.com/intent/tweet?#{URI.encode_query(%{text: @text, url: @url})}"}
        target="_blank"
        rel="nofollow noopener noreferrer"
        phx-click="sns_up_click"
      >
        <img class="h-6 w-24" src="/images/share_button/share_twitter.png" />
      </a>
    """
  end

  defp facebook_share_button(assigns) do
    ~H"""
      <a
        id={@id}
        href={"https://www.facebook.com/share.php?#{URI.encode_query(%{u: @url})}"}
        target="_blank"
        rel="nofollow noopener noreferrer"
        phx-click="sns_up_click"
      >
        <img class="h-6 w-24" src="/images/share_button/share_facebook.png" />
      </a>
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
    <button type="button" onclick={@url} class="flex h-[18px] lg:h-[26px]">
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
    <img src={@src} class="w-[18px] h-[18px] lg:w-[26px] lg:h-[26px]" />
    """
  end

  defp disable_icon_suffix(true), do: "_gray.svg"
  defp disable_icon_suffix(false), do: ".svg"
end
