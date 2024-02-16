defmodule BrightWeb.CardLive.RelatedUserCardComponent do
  @moduledoc """
  Related Users Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents
  import BrightWeb.DisplayUserHelper, only: [encrypt_user_name: 1]

  alias Bright.Accounts
  alias Bright.Teams
  alias Bright.CustomGroups
  alias Bright.UserProfiles
  alias Bright.RecruitmentStockUsers

  @tabs [
    # 気になる人はβリリース対象外のため非表示
    # {"intriguing", "気になる人"},
    {"team", "所属チーム"},
    {"custom_group", "カスタムグループ"},
    {"candidate_for_employment", "採用候補者"}
  ]

  @nobody_exists_message %{
    "team" => "所属しているチームはありません",
    "custom_group" => "カスタムグループはありません",
    "candidate_for_employment" => "採用候補者はいません"
  }

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
      |> assign(:hr_enabled, false)

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
        <div class="pt-3 pb-1 px-6 lg:min-h-[192px]">
          <% # TODO ↓α版対応 %>
          <ul :if={@selected_tab == "intriguing"} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                βリリース（11月予定）で利用可能になります
              </div>
            </li>
          </ul>
          <% # TODO ↑α版対応 %>
          <% # TODO ↓α版対応 @selected_tab == "joined_teams" && の条件を削除 %>
          <ul :if={@selected_tab != "intriguing" && Enum.count(@user_profiles) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                <%= Map.get(nobody_exists_message(), @selected_tab) %>
              </div>
            </li>
          </ul>
          <ul :if={Enum.count(@user_profiles) > 0} class="flex flex-col lg:flex-row lg:flex-wrap gap-y-1">
            <%= for user_profile <- @user_profiles do %>
              <%= if @selected_tab in ["team", "custom_group"] do %>
                <.profile_small
                  user_name={user_profile.user_name}
                  title={user_profile.title}
                  icon_file_path={user_profile.icon_file_path}
                  encrypt_user_name={user_profile.encrypt_user_name}
                  click_event={click_event(@purpose)}
                  click_target={@card_row_click_target}
                />
              <% else %>
                <.profile_stock_small_with_remove_button
                  stock_id={user_profile.id}
                  user_id={user_profile.user_id}
                  stock_date={Date.to_iso8601(user_profile.inserted_at)}
                  skill_panel={user_profile.skill_panel}
                  desired_income={if user_profile.desired_income == 0, do: "-" ,else: user_profile.desired_income}
                  encrypt_user_name={encrypt_user_name(user_profile.user)}
                  remove_user_target={@myself}
                  hr_enabled={@hr_enabled}
                  click_event={click_event(@purpose)}
                  click_target={@card_row_click_target}
                />
              <% end %>
            <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:hr_enabled, Accounts.hr_enabled?(assigns.current_user.id))
      # 初期表示データの取得 mount時に設定したselected_tabの選択処理を実行
      |> assign_with_seleted_tab()

    {:ok, socket}
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => selected_tab}, socket) do
    socket =
      socket
      |> assign(:selected_tab, selected_tab)
      |> assign_with_seleted_tab()

    {:noreply, socket}
  end

  def handle_event(
        "inner_tab_click",
        %{
          "tab_name" => selected_tab_name,
          "inner_tab_name" => inner_tab_id
        },
        socket
      ) do
    # 内部タブを選択されたタブに設定し、1ページ目のデータをアサイン
    # チームやカスタムグループなどが対象
    socket =
      socket
      |> assign(:inner_selected_tab, inner_tab_id)
      |> assign(:page, 1)
      |> assign_selected_card(selected_tab_name)

    {:noreply, socket}
  end

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

  def handle_event("remove_user", %{"stock_id" => id}, socket) do
    RecruitmentStockUsers.get_recruitment_stock_user!(id)
    |> RecruitmentStockUsers.delete_recruitment_stock_user()

    socket
    |> assign_selected_card("candidate_for_employment")
    |> then(&{:noreply, &1})
  end

  defp assign_with_seleted_tab(socket) do
    %{selected_tab: selected_tab} = socket.assigns

    socket
    |> assign_inner_tab(selected_tab)
    |> assign_first_inner_tab()
    |> assign_selected_card(selected_tab)
  end

  defp set_menu_items(false), do: []
  defp set_menu_items(_), do: @menu_items

  defp inner_tab(assigns) do
    ~H"""
    <div id={"#{@id}-#{@selected_tab}"} class="flex border-b border-brightGray-50 lg:w-[750px]" phx-hook="TabSlideScroll">
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

  defp assign_inner_tab(socket, "team") do
    # 所属チームの一覧を取得
    page =
      Teams.list_joined_teams_by_user_id(
        socket.assigns.current_user.id,
        # TODO inner_tab内のチーム一覧のページング実装
        %{page: 1, page_size: 999}
      )

    inner_tab =
      page.entries
      |> Enum.map(fn member_user ->
        {member_user.team.id, member_user.team.name}
      end)

    assign(socket, :inner_tab, inner_tab)
  end

  defp assign_inner_tab(socket, "custom_group") do
    # カスタムグループの一覧を取得
    inner_tab =
      CustomGroups.list_user_custom_groups(socket.assigns.current_user.id)
      |> Enum.map(&{&1.id, &1.name})

    assign(socket, :inner_tab, inner_tab)
  end

  defp assign_inner_tab(socket, _) do
    assign(socket, :inner_tab, [])
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

  defp assign_selected_card(socket, "custom_group") do
    %{inner_selected_tab: custom_group_id, current_user: current_user} = socket.assigns

    custom_group =
      custom_group_id &&
        CustomGroups.get_custom_group_by(
          id: custom_group_id,
          user_id: current_user.id
        )

    if custom_group do
      member_users_page =
        CustomGroups.list_member_users(
          custom_group,
          %{
            page: socket.assigns.page,
            page_size: socket.assigns.page_size
          }
        )

      user_profiles =
        member_users_page.entries
        |> Enum.map(&build_user_profile(&1.user))

      socket
      |> assign(:user_profiles, user_profiles)
      |> assign(:total_pages, member_users_page.total_pages)
    else
      socket
      |> assign(:user_profiles, [])
      |> assign(:total_pages, 0)
    end
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

    socket
    |> assign(:user_profiles, list_recruitment_stock_users)
    |> assign(:total_pages, list_recruitment_stock_users.total_pages)
  end

  defp assign_selected_card(socket, _) do
    socket
    |> assign(:user_profiles, [])
    |> assign(:total_pages, 1)
  end

  defp assign_first_inner_tab(socket) do
    # 内部タブがあるなら最初の1つを自動選択する
    socket.assigns.inner_tab
    |> List.first()
    |> case do
      nil ->
        socket

      {first_inner_tab_id, _first_tab_name} ->
        assign(socket, :inner_selected_tab, first_inner_tab_id)
    end
  end

  defp get_team_member_user_profiles(_user_id, nil, _page_params) do
    %{user_smalls: [], total_pages: 0}
  end

  defp get_team_member_user_profiles(user_id, team_id, page_params) do
    page =
      Teams.list_joined_users_and_profiles_by_team_id_without_myself(
        user_id,
        team_id,
        page_params
      )

    member_and_users = Enum.map(page.entries, &build_user_profile(&1.user))

    %{user_smalls: member_and_users, total_pages: page.total_pages}
  end

  defp build_user_profile(user) do
    %{
      user_name: user.name,
      title: user.user_profile.title,
      icon_file_path: UserProfiles.icon_url(user.user_profile.icon_file_path),
      encrypt_user_name: ""
    }
  end

  defp click_event(nil), do: nil

  defp click_event(purpose), do: "click_on_related_user_card_#{purpose}"

  defp nobody_exists_message, do: @nobody_exists_message
end
