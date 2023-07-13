defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component

  @doc """
  Renders a User Header

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までユーザーヘッダーのみ部品デザイン更新

  ## Examples
      <.user_header />
  """
  def user_header(assigns) do
    ~H"""
    <div class="w-full flex justify-between py-2.5 px-10 border-brightGray-100 border-b bg-white">
      <h4>マイページ</h4>
      <div class="flex gap-x-5">
        <.contact_customer_success_button />
        <.search_for_skill_holders_button />
        <.bell_button />
        <.user_button />
      </div>
    </div>
    """
  end

  # TODO ↓ BrightButtonComponentsに移動予定

  @doc """
  Renders a Contact Customer Success Button

  ## Examples
      <.contact_customer_success_button />
  """
  def contact_customer_success_button(assigns) do
    ~H"""
    <button type="button"
      class="text-white bg-brightGreen-300 px-4 inline-flex rounded-md text-sm items-center font-bold h-9 hover:opacity-70">
      <span
          class="bg-white material-icons mr-1 !text-base !text-brightGreen-300 rounded-full h-6 w-6 !font-bold material-icons-outlined">sms</span>
      カスタマーサクセスに連絡
    </button>
    """
  end

  @doc """
  Renders a Search for Skill Holders Button

  ## Examples
      <.search_for_skill_holders_button />
  """
  def search_for_skill_holders_button(assigns) do
    ~H"""
    <button type="button"
      class="text-white bg-brightGreen-300 px-4 inline-flex rounded-md text-sm items-center font-bold h-9 hover:opacity-70">
      <span
          class="bg-white material-icons mr-1 !text-base !text-brightGreen-300 rounded-full h-6 w-6 !font-bold">search</span>
      スキル保有者を検索
    </button>
    """
  end

  @doc """
  Renders a Bell Button

  ## Examples
      <.bell_button />
  """
  def bell_button(assigns) do
    ~H"""
    <button type="button"
      class="text-black bg-brightGray-50 hover:bg-brightGray-100 rounded-full w-10 h-10 inline-flex items-center justify-center relative">
      <span class="material-icons">notifications_none</span>
      <div
          class="absolute inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-attention-600 rounded-full -top-0 -right-2">
          1
      </div>
    </button>
    """
  end

  @doc """
  Renders a User Button

  ## Examples
      <.button />
  """
  def user_button(assigns) do
    ~H"""
    <button id="user_menu_dropmenu" class="hover:opacity-70" data-dropdown-toggle="user_menu">
      <img class="inline-block h-10 w-10 rounded-full"
          src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80" />
    </button>
    <.user_menu />
    """
  end

  defp user_menu(assigns) do
    menu_items = [
      %{text: "個人設定", href: "/", method: "get"},
      %{text: "ログアウトする", href: "/users/log_out", method: "delete"}
    ]

    assigns =
      assigns
      |> assign(:menu_items, menu_items)

    ~H"""
    <div
      id="user_menu"
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
    >
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="user_menu_dropmenu">
        <%= for menu_item <- @menu_items do %>
          <.user_menu_item menu_item={menu_item}/>
        <% end %>
      </ul>
    </div>
    """
  end

  attr :menu_item, :map

  defp user_menu_item(assigns) do
    ~H"""
        <li>

        <.link
        href={@menu_item.href}
        method={@menu_item.method}
        class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
        >
        <%= @menu_item.text %>
      </.link>

        </li>
    """
  end

  # TODO ↑ BrightButtonComponentsに移動予定

  @doc """
  Renders a Side Menu

  ## Examples
      <.side_menu />
  """
  def side_menu(assigns) do
    ~H"""
    <aside class="flex bg-brightGray-900 min-h-screen flex-col w-[200px] pt-6 pl-3">
      <img src="/images/common/logo.svg" } width="163px" />
      <ul class="grid gap-y-10 pl-5 pt-6">
        <li>
          <a class="!text-white text-base" href="/mypage">マイページ</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">キャリアパス</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">スキルアップ</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">チームスキル分析</a>
        </li>
      </ul>
    </aside>
    """
  end
end
