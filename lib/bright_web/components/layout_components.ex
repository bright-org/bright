defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  import BrightWeb.UserMenuComponents
  alias Bright.UserProfiles

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
        <.bell_button notification_count={@notification_count}/>
        <.user_button icon_file_path={@profile.icon_file_path}/>
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
      {"成長を見る・比較する", "/"},
      {"スキルパネルを入力", "/panels/dummy_id/graph"},
      {"スキルアップを目指す", "/"},
      {"チームスキル分析", "/"},
      {"キャリアパスを選ぶ", "/"}
    ]
  end

  defp menu_active_style(true),
    do: "!text-white bg-white bg-opacity-30 text-base py-4 inline-block pl-4 w-full mb-1"

  defp menu_active_style(false), do: "!text-white text-base py-4 inline-block pl-4 w-full mb"
end
