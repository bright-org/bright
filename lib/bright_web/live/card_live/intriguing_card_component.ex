# TODO 「bfa3829b2692f756ab89e228d923ca1516edf31b」　「feat: さまざまな人たちとの交流 にボタン追加」　までデザイン更新
defmodule BrightWeb.CardLive.IntriguingCardComponent do
  @moduledoc """
  Intriguing Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  @tabs [
    {"intriguing", "気になる人"},
    {"team", "チーム"},
    {"candidate_for_employment", "採用候補者"}
  ]

  @menu_items [%{text: "カスタムグループを作る", href: "/"}, %{text: "カスタムグループの編集", href: "/"}]

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:menu_items, set_menu_items(assigns[:display_menu]))
      |> assign(:tabs, @tabs)
      |> assign(:selected_tab, "intriguing")
      # TODO サンプルデータです　ここにDBから取得した結果をセットしてください
      |> assign(:user_profiles, sample())

    ~H"""
    <div>
      <.tab
        id="intriguing_card"
        tabs={@tabs}
        selected_tab={@selected_tab}
        menu_items={@menu_items}
        target={@myself}
      >
        <.inner_tab />
        <div class="pt-3 pb-1 px-6">
          <ul class="flex flex-wrap gap-y-1">
            <%= for user_profile <- @user_profiles do %>
              <.profile_small user_name={user_profile.user_name} title={user_profile.title} icon_file_path={user_profile.icon_file_path} />
            <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "intriguing_card"},
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "previous_button_click",
        %{"id" => "intriguing_card"},
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "next_button_click",
        %{"id" => "intriguing_card"},
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    {:noreply, socket}
  end

  def set_menu_items(false), do: []
  def set_menu_items(_), do: @menu_items

  defp inner_tab(assigns) do
    assigns =
      assigns
      |> assign(:inner_tab, inner_tabs_sample())
      |> assign(:inner_selected_tab, "tab3")

    ~H"""
    <div class="flex border-b border-brightGray-50">
      <div class="overflow-hidden">
        <ul class="overflow-hidden flex text-base !text-sm w-[800px]" >
          <%= for {key, value} <- @inner_tab do %>
            <li class={["py-2 w-[200px] border-r border-brightGray-50", key == @inner_selected_tab  && "bg-brightGreen-50" ]}>
              <%= value %>
            </li>
          <% end %>
        </ul>
      </div>
      <button class="px-1 border-l border-brightGray-50">
        <span
          class="w-0 h-0 border-solid border-l-0 border-r-[10px] border-r-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"
        ></span>
      </button>
      <button class="px-1 border-l border-brightGray-50">
        <span
          class="w-0 h-0 border-solid border-r-0 border-l-[10px] border-l-brightGray-300 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent inline-block"
        ></span>
      </button>
    </div>
    """
  end

  # TODO サンプルデータです　DBの取得処理を追加後削除してください
  defp sample() do
    [
      %{
        user_name: "サンプルデータ",
        title: "このデータはDBから取得してません",
        icon_file_path:
          "https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
      },
      %{
        user_name: "user2",
        title: "固定データです",
        icon_file_path:
          "https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
      }
    ]
  end

  # TODO サンプルデータです　DBの取得処理を追加後削除してください
  defp inner_tabs_sample() do
    [
      {"tab1", "キャリアの参考になる方々"},
      {"tab2", "優秀なエンジニアの方々"},
      {"tab3", "カスタムグループ３"},
      {"tab4", "カスタムグループ４"}
    ]
  end
end
