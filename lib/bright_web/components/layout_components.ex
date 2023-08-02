defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  alias Bright.UserProfiles

  @doc """
  Renders root layout.
  """

  attr :csrf_token, :string, required: true
  attr :page_title, :string

  slot :inner_block, required: true

  def root_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="ja">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={@csrf_token} />
        <.live_title>
          <%= @page_title || "Bright" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={"/assets/app.js"}>
        </script>
        <link rel="icon" href={"/favicon.ico"} />
      </head>
      <%= render_slot(@inner_block) %>
    </html>
    """
  end

  @doc """
  Renders a User Header

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までユーザーヘッダーのみデザイン更新

  ## Examples
      <.user_header />
  """
  attr :profile, :map
  attr :page_title, :string
  attr :page_sub_title, :string
  attr :notification_count, :integer

  def user_header(assigns) do
    page_sub_title =
      if assigns.page_sub_title != nil, do: " / #{assigns.page_sub_title}", else: ""

    assigns =
      assigns
      |> assign(:profile, assigns.profile || %UserProfiles.UserProfile{})
      |> assign(:notification_count, assigns.notification_count || 0)
      |> assign(:page_sub_title, page_sub_title)

    ~H"""
    <div class="w-full flex justify-between py-2.5 px-10 border-brightGray-100 border-b bg-white">
      <h4><%= @page_title %><%= @page_sub_title %></h4>
      <div class="flex gap-x-5">
        <.contact_customer_success_button />
        <.search_for_skill_holders_button />
        <.user_button icon_file_path={@profile.icon_file_path}/>
        <.logout_button />
      </div>
    </div>
    """
  end

  @doc """
  Renders a Side Menu

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までメニューのみデザイン更新

  ## Examples
      <.side_menu />
  """

  attr :href, :string

  def side_menu(assigns) do
    ~H"""
    <aside
    class="flex bg-brightGray-900 min-h-screen flex-col w-[200px] pt-3"
    >
      <.link href="/mypage"><img src="/images/common/logo.svg" width="163px" class="ml-4" /></.link>
      <ul class="grid pt-2">
        <%= for {title, path} <- links() do %>
          <li>
            <.link class={menu_active_style(path == @href)} href={path} ><%= title %></.link>
          </li>
        <% end %>
      </ul>
    </aside>
    """
  end

  def links() do
    [
      {"スキルを選ぶ", "/onboardings"},
      {"成長を見る・比較する", "/panels/dummy_id/graph"},
      {"スキルパネルを入力", "/"},
      {"スキルアップを目指す", "/"},
      {"チームスキル分析", "/teams"},
      {"キャリアパスを選ぶ", "/"}
    ]
  end

  defp menu_active_style(true),
    do: "!text-white bg-white bg-opacity-30 text-base py-4 inline-block pl-4 w-full mb-1"

  defp menu_active_style(false), do: "!text-white text-base py-4 inline-block pl-4 w-full mb"
end
