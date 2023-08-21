defmodule BrightWeb.BrightButtonComponents do
  @moduledoc """
  Bright Button Components
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a Profile Button

  ## Examples

       <.profile_button>自分に戻す</.profile_button>
  """
  slot :inner_block
  attr :rest, :global

  def profile_button(assigns) do
    ~H"""
    <button
      type="button"
      class="text-brightGreen-300 bg-white px-2 py-1 inline-flex rounded-md text-sm items-center border border-brightGreen-300 font-bold"
      {@rest}
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
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border hover:border-brightGreen-300 group"
    >
      <span class="material-icons md-18 mr-1 text-brightGray-200 group-hover:text-brightGreen-300">share</span> 優秀な人として紹介
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
      class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200 hover:border-brightGreen-300 group"
    >
      <span class="material-icons md-18 mr-1 text-brightGray-200 group-hover:text-brightGreen-300">star</span> 気になる
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
    <button
      type="button"
      class="text-white bg-brightGreen-300 px-4 inline-flex rounded-md text-sm items-center font-bold h-9 hover:opacity-70"
      phx-click={JS.toggle(to: "#skill_search_modal")}
      phx-target={"#skill_search"}
    >
      <span
          class="bg-white material-icons mr-1 !text-base !text-brightGreen-300 rounded-full h-6 w-6 !font-bold">search</span>
      スキル保有者を検索
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
      class="hover:opacity-70 z-20"
      phx-click={JS.toggle(to: "#personal_setting_modal")}
      phx-target={"#personal_settings"}
    >
      <img
        class="inline-block h-10 w-10 rounded-full"
        src={@icon_file_path}
      />
    </button>
    """
  end

  def logout_button(assigns) do
    ~H"""
        <.link
          href="/users/log_out"
          method="delete"
          class="hover:opacity-70"
          >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-10 w-10 stroke-red-400">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15m3 0l3-3m0 0l-3-3m3 3H9" />
          </svg>
        </.link>
    """
  end
end
