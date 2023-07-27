defmodule BrightWeb.BrightButtonComponents do
  @moduledoc """
  Bright Button Components
  """
  use Phoenix.Component

  @doc """
  Renders a Profile Button

  ## Examples

       <.profile_button>自分に戻す</.profile_button>
  """
  slot :inner_block

  def profile_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a "Excellent Person" Button

  ## Examples

      <.excellent_person_button />
  """
  def excellent_person_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGreen-300"
    >
      <span class="material-icons md-18 mr-1 text-brightGreen-300">share</span> 優秀な人として紹介
    </button>
    """
  end

  @doc """
  Renders a "Anxious Person" Button

  ## Examples

      <.anxious_person_button />
  """
  def anxious_person_button(assigns) do
    ~H"""
    <button
      type="button"
      id="dropcheckmenu"
      data-dropdown-toggle="checkmenu"
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
    >
      <span class="material-icons md-18 mr-1 text-brightGray-200">star</span> 気になる
    </button>
    <!-- 気になるDropdown menu -->
    <div id="checkmenu" class="z-10 hidden bg-white rounded-lg shadow min-w-[286px]">
      <ul class="p-2 text-left text-base" aria-labelledby="dropcheckmenu">
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">気になるリスト</a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">メンバー候補</a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            java開発者リスト
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            Python開発者リスト
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            ジュニアエンジニア
          </a>
        </li>
        <li>
          <a href="#" class="block px-4 py-3 hover:bg-brightGray-50 text-base">
            シニアエンジニア
          </a>
        </li>
        <li class="px-4 py-3 hover:bg-brightGray-50 flex justify-center gap-x-2">
          <input
            type="text"
            placeholder="リスト名を入力"
            class="px-2 py-1 border border-brightGray-900 rounded-sm flex-1 w-full text-base w-[220px]"
          />
          <button class="text-sm font-bold px-4 py-1 rounded text-white bg-base">
            新規作成
          </button>
        </li>
      </ul>
    </div>
    """
  end

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

      <.bell_button notification_count=99 />
  """
  attr :notification_count, :integer

  def bell_button(assigns) do
    ~H"""
    <button type="button"
      class="text-black bg-brightGray-50 hover:bg-brightGray-100 rounded-full w-10 h-10 inline-flex items-center justify-center relative">
      <span class="material-icons">notifications_none</span>
      <%= if @notification_count > 0 do %>
        <div
            class="absolute inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-attention-600 rounded-full -top-0 -right-2">
            <%= @notification_count %>
        </div>
      <% end %>
    </button>
    """
  end

  @doc """
  Renders a User Button

  ## Examples

      <.user_button icon_file_path="/images/sample/sample-image.png" />
  """
  attr :icon_file_path, :string

  def user_button(assigns) do
    ~H"""
    <button
      id="user_menu_dropmenu"
      class="hover:opacity-70"
      phx-click={Phoenix.LiveView.JS.toggle(
        to: "#personal_settings",
        in: {"ease-in-out duration-500 both", "scale-y-0 origin-top", "scale-y-100"},
        out: {"ease-in-out duration-500 both", "scale-y-100", "scale-y-0 origin-top"},
        time: 500
      )}
      phx-target={"#personal_settings"}
    >
      <img class="inline-block h-10 w-10 rounded-full"
          src={@icon_file_path} />
    </button>
    """
  end

  defp user_menu(assigns) do
    menu_items = [
      %{text: "個人設定", href: "/settings/general", method: "get"},
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
end
