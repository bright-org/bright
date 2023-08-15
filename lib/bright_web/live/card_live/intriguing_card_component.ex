# TODO 「bfa3829b2692f756ab89e228d923ca1516edf31b」　「feat: さまざまな人たちとの交流 にボタン追加」　までデザイン更新
defmodule BrightWeb.CardLive.IntriguingCardComponent do
  @moduledoc """
  Intriguing Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  alias Bright.Teams

  @tabs [
    # αリリース対象外 {"intriguing", "気になる人"},
    {"team", "チーム"}
    # αリリース対象外 {"candidate_for_employment", "採用候補者"}
  ]

  @menu_items [
    # αリリース対象外 %{text: "カスタムグループを作る", href: "/"}, %{text: "カスタムグループの編集", href: "/"}
  ]

  @impl true
  def mount(socket) do
    IO.puts("### mount #############################")

    socket =
      socket
      |> assign(:current_user, nil)
      |> assign(:menu_items, nil)
      |> assign(:tabs, @tabs)
      # TODO タブが増えたら初期選択タブの変更に対応する
      |> assign(:selected_tab, "team")
      |> assign(:user_profiles, [])
      |> assign(:inner_tab, [])
      |> assign(:inner_selected_tab, nil)

    {:ok, socket}
  end

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="intriguing_card#{@id}"
        tabs={@tabs}
        selected_tab={@selected_tab}
        menu_items={@menu_items}
        target={@myself}
      >
        <.inner_tab
          target={@myself}
          inner_tab={@inner_tab}
          inner_selected_tab={@inner_selected_tab}
        />
        <div class="pt-3 pb-1 px-6 min-h-[192px]">
          <ul :if={Enum.count(@user_profiles) == 0} class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
              <%= Enum.into(@tabs, %{}) |> Map.get(@selected_tab) %>はいません
              </div>
            </li>
          </ul>
          <ul :if={Enum.count(@user_profiles) > 0} class="flex flex-wrap gap-y-1">
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
  def update(assigns, socket) do
    page =
      Teams.list_joined_teams_by_user_id(
        assigns.current_user.id,
        # TODO チーム一覧のページング
        %{page: 1, page_size: 99999}
      )

    inner_tabs =
      page.entries
      |> Enum.map(fn member_user ->
        {member_user.team.id, member_user.team.name}
      end)

    first_member_user =
      page.entries
      |> List.first()

    first_team_id = first_member_user.team.id
    first_tab_name = first_team_id

    # mount直後のupdate時は最初のタブを自動選択
    inner_selected_tab =
      if socket.assigns.inner_selected_tab == nil do
        first_tab_name
      else
        socket.assigns.inner_selected_tab
      end

    user_profile = get_team_member_user_profiles(inner_selected_tab)

    {
      :ok,
      socket =
        socket
        |> assign(:current_user, assigns.current_user)
        |> assign(:menu_items, set_menu_items(assigns[:display_menu]))
        |> assign(:selected_tab, socket.assigns.selected_tab)
        |> assign(:user_profiles, user_profile)
        |> assign(:inner_tab, inner_tabs)
        |> assign(:inner_selected_tab, inner_selected_tab)
    }
  end

  @doc """
  チームタブクリック時の挙動

  所属しているチームの一覧を取得する
  """
  @impl true
  def handle_event(
        "tab_click",
        %{"id" => id, "tab_name" => "team"},
        socket
      ) do
    # TODO これは雛形です処理を記述すること

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => id, "tab_name" => tab_name},
        socket
      ) do
    # TODO これは雛形です処理を記述すること

    socket =
      socket
      |> assign(:selected_tab, tab_name)

    {:noreply, socket}
  end

  def handle_event(
        "inner_tab_click",
        %{"tab_name" => team_id},
        socket
      ) do
    socket =
      socket
      |> assign(:inner_selected_tab, team_id)
      |> assign(:user_profiles, get_team_member_user_profiles(team_id))

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "previous_button_click",
        %{"id" => id},
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "next_button_click",
        %{"id" => id},
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    {:noreply, socket}
  end

  def set_menu_items(false), do: []
  def set_menu_items(_), do: @menu_items

  defp inner_tab(assigns) do
    ~H"""
    <div class="flex border-b border-brightGray-50">
      <div class="overflow-hidden">
        <ul id="relational_user_tab" class="overflow-hidden flex text-base !text-sm w-[99999px]" >
          <%= for {key, value} <- @inner_tab do %>
            <li
              class={["p-2 select-none cursor-pointer truncate w-[200px] border-r border-brightGray-50", key == @inner_selected_tab  && "bg-brightGreen-50" ]}
              phx-click="inner_tab_click"
              phx-target={@target}
              phx-value-tab_name={key}
            >
              <%= value %>
            </li>
          <% end %>
        </ul>
      </div>
      <div id="relational_user_tab_buttons" class="flex">
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

  defp assign_current_user_teams(assigns) do
    page =
      Teams.list_joined_teams_by_user_id(
        assigns.current_user.id,
        # TODO チーム一覧のページング
        %{page: 1, page_size: 99999}
      )

    inner_tabs =
      page.entries
      |> Enum.map(fn member_user ->
        {member_user.team.id, member_user.team.name}
      end)

    first_member_user =
      page.entries
      |> List.first()

    first_team_id = first_member_user.team.id
    first_tab_name = first_team_id

    assigns =
      assigns
      |> assign(:selected_tab, "team")
      |> assign(:inner_tab, inner_tabs)
      |> assign(:inner_selected_tab, first_tab_name)
      |> assign(:user_profiles, get_team_member_user_profiles(first_team_id))
  end

  defp get_team_member_user_profiles(team_id) do
    page =
      Teams.list_jined_users_and_profiles_by_team_id(
        team_id,
        # TODO タブ内でのページング
        %{page: 1, page_size: 10}
      )

    page.entries
    |> Enum.map(fn member_users ->
      member_users.user.user_profile

      %{
        user_name: member_users.user.name,
        title: member_users.user.user_profile.title,
        icon_file_path:
          "https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
        # TODO アイコンの設定が動いたら置き換え member_users.user.user_profile.icon_file_path,
      }
    end)
  end
end
