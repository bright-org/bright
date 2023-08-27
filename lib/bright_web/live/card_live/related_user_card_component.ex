# TODO 「bfa3829b2692f756ab89e228d923ca1516edf31b」　「feat: さまざまな人たちとの交流 にボタン追加」　までデザイン更新
defmodule BrightWeb.CardLive.RelatedUserCardComponent do
  @moduledoc """
  Related Users Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  alias Bright.Teams
  alias Bright.UserProfiles
  alias Bright.RecruitmentStockUsers
  alias BrightWeb.DisplayUserHelper

  @tabs [
    {"intriguing", "気になる人"},
    {"team", "チーム"},
    {"candidate_for_employment", "採用候補者"}
  ]

  @menu_items [
    # αリリース対象外 %{text: "カスタムグループを作る", href: "/"}, %{text: "カスタムグループの編集", href: "/"}
  ]

  @page_size 6

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:current_user, nil)
      |> assign(:menu_items, set_menu_items(socket.assigns[:display_menu]))
      |> assign(:tabs, @tabs)
      # TODO タブが増えたら初期選択タブの変更に対応する
      |> assign(:selected_tab, "team")
      |> assign(:user_profiles, [])
      |> assign(:inner_tab, [])
      |> assign(:inner_selected_tab, nil)
      |> assign(:page, 1)
      |> assign(:total_pages, 0)
      |> assign(:page_size, @page_size)
      |> assign(:card_row_click_target, nil)
      |> assign(:purpose, nil)

    {:ok, socket}
  end

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id={"related-user-card-#{@id}"}
        tabs={@tabs}
        selected_tab={@selected_tab}
        menu_items={@menu_items}
        target={@myself}
        page={@page}
        total_pages={@total_pages}
      >
        <.inner_tab
          :if={Enum.count(@inner_tab) > 0}
          id={"related-user-card-inner-tab-#{@id}"}
          target={@myself}
          selected_tab={@selected_tab}
          inner_tab={@inner_tab}
          inner_selected_tab={@inner_selected_tab}
        />
        <div class="pt-3 pb-1 px-6 min-h-[192px]">
          <% # TODO ↓α版対応 %>
          <ul :if={@selected_tab == "intriguing"} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                βリリース（10月予定）で利用可能になります
              </div>
            </li>
          </ul>
          <% # TODO ↑α版対応 %>
          <% # TODO ↓α版対応 @selected_tab == "joined_teams" && の条件を削除 %>
          <ul :if={@selected_tab != "intriguing" && Enum.count(@user_profiles) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>はいません
              </div>
            </li>
          </ul>
          <ul :if={Enum.count(@user_profiles) > 0} class="flex flex-wrap gap-y-1">
            <%= for user_profile <- @user_profiles do %>
              <.profile_small user_name={user_profile.user_name} title={user_profile.title} icon_file_path={user_profile.icon_file_path} encrypt_user_name={user_profile.encrypt_user_name} click_event={click_event(@purpose)} click_target={@card_row_click_target} />
            <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket |> assign(assigns)

    # 初期表示データの取得 mount時に設定したselected_tabの選択処理を実行
    {:noreply, socket} =
      handle_event(
        "tab_click",
        %{"id" => assigns.id, "tab_name" => socket.assigns.selected_tab},
        socket
      )

    {:ok, socket}
  end

  @doc """
  チームタブクリック時の挙動

  所属しているチームの一覧を取得する
  """
  @impl true
  def handle_event(
        "tab_click",
        %{"id" => _id, "tab_name" => "team"},
        socket
      ) do
    # inner_tab用に所属チームの一覧を取得
    page =
      Teams.list_joined_teams_by_user_id(
        socket.assigns.current_user.id,
        # TODO inner_tab内のチーム一覧のページング実装
        %{page: 1, page_size: 999}
      )

    inner_tabs =
      page.entries
      |> Enum.map(fn member_user ->
        {member_user.team.id, member_user.team.name}
      end)

    socket =
      socket
      |> assign(:selected_tab, "team")
      |> assign(:inner_tab, inner_tabs)

    # チームが１以上あるなら最初のinner_tabを自動選択してcartの中身更新する
    socket =
      if length(inner_tabs) >= 1 do
        first_member_users =
          page.entries
          |> List.first()

        first_member_users.team.id

        {:noreply, socket} =
          handle_event(
            "inner_tab_click",
            %{
              "tab_name" => "team",
              "inner_tab_name" => first_member_users.team.id
            },
            socket
          )

        socket
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => _id, "tab_name" => "candidate_for_employment"},
        socket
      ) do
    socket =
      socket
      |> assign(:selected_tab, "candidate_for_employment")
      |> assign(:inner_tab, [])
      |> assign_selected_card("candidate_for_employment")

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => _id, "tab_name" => tab_name},
        socket
      ) do
    # TODO これは雛形です処理を記述すること

    socket =
      socket
      |> assign(:selected_tab, tab_name)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "inner_tab_click",
        %{
          "tab_name" => "team",
          "inner_tab_name" => team_id
        },
        socket
      ) do
    socket =
      socket
      # 選択中のinnserタブを変更
      |> assign(:inner_selected_tab, team_id)
      # １ページ目にリセット
      |> assign(:page, 1)
      # 選択中のタブ名に応じたassign_selected_cardを実行
      |> assign_selected_card(socket.assigns.selected_tab)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "previous_button_click",
        %{"id" => _id},
        socket
      ) do
    page = socket.assigns.page - 1
    page = if page < 1, do: 1, else: page

    socket =
      socket
      |> assign(:page, page)
      # 選択中のタブ名に応じたassign_selected_cardを実行
      |> assign_selected_card(socket.assigns.selected_tab)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "next_button_click",
        %{"id" => _id},
        socket
      ) do
    socket =
      socket
      |> assign(:page, socket.assigns.page + 1)
      # 選択中のタブ名に応じたassign_selected_cardを実行
      |> assign_selected_card(socket.assigns.selected_tab)

    {:noreply, socket}
  end

  def set_menu_items(false), do: []
  def set_menu_items(_), do: @menu_items

  defp inner_tab(assigns) do
    ~H"""
    <div id={@id} class="flex border-b border-brightGray-50" phx-hook="TabSlideScroll">
      <div class="overflow-hidden">
        <ul class="inner_tab_list overflow-hidden flex text-base !text-sm w-[99999px]">
          <%= for {key, value} <- @inner_tab do %>
            <li
              class={["p-2 select-none cursor-pointer truncate w-[200px] border-r border-brightGray-50", key == @inner_selected_tab  && "bg-brightGreen-50" ]}
              phx-click="inner_tab_click"
              phx-target={@target}
              phx-value-tab_name={@selected_tab}
              phx-value-inner_tab_name={key}
            >
              <%= value %>
            </li>
          <% end %>
        </ul>
      </div>
      <div class="inner_tab_slide_buttons flex">
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
    </div>
    """
  end

  defp assign_selected_card(socket, "team") do
    member_and_users =
      get_team_member_user_profiles(
        socket.assigns.current_user.id,
        socket.assigns.inner_selected_tab,
        %{
          page: socket.assigns.page,
          page_size: socket.assigns.page_size
        }
      )

    socket
    |> assign(:user_profiles, member_and_users.user_smalls)
    |> assign(:total_pages, member_and_users.total_pages)
  end

  defp assign_selected_card(socket, "candidate_for_employment") do
    list_recruitment_stock_users =
      RecruitmentStockUsers.list_recruitment_stock_users(
        socket.assigns.current_user.id,
        %{
          page: socket.assigns.page,
          page_size: socket.assigns.page_size
        }
      )

    user_profiles =
      list_recruitment_stock_users
      |> Enum.map(fn user ->
        %{
          user_name: "非表示",
          title: "非表示",
          icon_file_path: UserProfiles.icon_url(nil),
          encrypt_user_name: DisplayUserHelper.encrypt_user_name(user)
        }
      end)

    socket
    |> assign(:user_profiles, user_profiles)
    |> assign(:total_pages, list_recruitment_stock_users.total_pages)
  end

  defp get_team_member_user_profiles(user_id, team_id, page_params) do
    page =
      Teams.list_joined_users_and_profiles_by_team_id_without_myself(
        user_id,
        team_id,
        page_params
      )

    member_and_users =
      page.entries
      |> Enum.map(fn member_users ->
        member_users.user.user_profile

        %{
          user_name: member_users.user.name,
          title: member_users.user.user_profile.title,
          icon_file_path: UserProfiles.icon_url(member_users.user.user_profile.icon_file_path),
          encrypt_user_name: ""
        }
      end)

    %{user_smalls: member_and_users, total_pages: page.total_pages}
  end

  defp click_event(nil), do: nil

  defp click_event(purpose), do: "click_on_related_user_card_#{purpose}"
end
