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
    <div class="flex-none flex gap-x-3 lg:gap-x-4 mt-1">
      <.icon_button sns_type="x" url={@twitter_url} />
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
  attr :skill_panel, :string, required: true
  attr :level_text, :string, default: nil
  attr :phx_click, :string, default: "sns_up_click"

  def sns_share_button_group(assigns) do
    assigns =
      assigns
      |> Map.put(:twitter_text, twitter_text(assigns.skill_panel, assigns.level_text))

    ~H"""
      <div
        id={@id}
        class="flex gap-2"
      >
        <.twitter_share_button id={"#{@id}-twitter"} url={@share_graph_url} text={@twitter_text} phx_click={@phx_click}/>
        <.facebook_share_button id={"#{@id}-facebook"} url={@share_graph_url} phx_click={@phx_click}/>
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
        phx-click={@phx_click}
      >
        <img class="h-6 w-24" src="/images/share_button/share_x.png" />
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
        phx-click={@phx_click}
      >
        <img class="h-6 w-24" src="/images/share_button/share_facebook.png" />
      </a>
    """
  end

  attr :url, :string
  attr :sns_type, :string, values: ~w(x github facebook)

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

  defp twitter_text(skill_panel, "start") do
    """
    \"#{skill_panel}\"スキルパネルをスタートしました！あなたも成長パネルを作成してみませんか？
    #bright_skill
    """
  end

  defp twitter_text(skill_panel, nil) do
    """
    \"#{skill_panel}\"スキルパネルをシェアしました！あなたも成長パネルを作成してみませんか？
    #bright_skill
    """
  end

  defp twitter_text(skill_panel, level_text) do
    """
    \"#{skill_panel}\"の「#{level_text}」にレベルアップしました！
    #bright_skill
    """
  end
end
