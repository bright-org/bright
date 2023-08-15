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

  @page_size 4

  @impl true
  def mount(socket) do
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
      |> assign(:page, 1)
      |> assign(:total_pages, 0)
      |> assign(:page_size, @page_size)

    {:ok, socket}
  end

  @impl true
  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do

    IO.puts("### render ########################")
    IO.inspect(assigns)

    ~H"""
    <div>
      <.tab
        id="intriguing_card#{@id}"
        tabs={@tabs}
        selected_tab={@selected_tab}
        menu_items={@menu_items}
        target={@myself}
        page={@page}
        total_pages={@total_pages}
      >
        <.inner_tab
          target={@myself}
          selected_tab={@selected_tab}
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
        %{page: 1, page_size: 999}
      )

    inner_tabs =
      page.entries
      |> Enum.map(fn member_user ->
        {member_user.team.id, member_user.team.name}
      end)

    # mount直後のupdate時、チームが１以上あるなら最初のタブを自動選択
    inner_selected_tab =
      if length(inner_tabs) >= 1 && socket.assigns.inner_selected_tab == nil do
        first_member_user =
          page.entries
          |> List.first()

        first_member_user.team.id
      else
        socket.assigns.inner_selected_tab
      end

    # チームが１以上あるなら該当チームメンバーの情報を取得
    member_and_users =
      if inner_selected_tab != nil do
        get_team_member_user_profiles(inner_selected_tab, %{
          page: socket.assigns.page,
          page_size: socket.assigns.page_size
        })
      else
        []
      end

    {
      :ok,
      socket =
        socket
        |> assign(:current_user, assigns.current_user)
        |> assign(:menu_items, set_menu_items(assigns[:display_menu]))
        |> assign(:selected_tab, socket.assigns.selected_tab)
        |> assign(:user_profiles, member_and_users.user_smalls)
        |> assign(:inner_tab, inner_tabs)
        |> assign(:inner_selected_tab, inner_selected_tab)
        |> assign(:page, page.page_number)
        |> assign(:total_pages, member_and_users.total_pages)
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

  @doc """
  チームタブのinnser_tab(=各所属チームのタブ)クリック時の処理

  該当チームの一覧の１ページ目を取得する
  """
  def handle_event(
        "inner_tab_click",
        %{
          "tab_name" => "team",
          "inner_tab_name" => team_id
        },
        socket
      ) do

        member_and_users = get_team_member_user_profiles(team_id, %{page: 1, page_size: socket.assigns.page_size})

    socket =
      socket
      |> assign(:inner_selected_tab, team_id)
      |> assign(
        :user_profiles,
        member_and_users.user_smalls
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "previous_button_click",
        %{"id" => id},
        socket
      ) do
    # TODO これは雛形です処理を記述すること

    page = socket.assgins.page - 1
    page = if page < 1, do: 1, else: page

    socket =
      socket
      |> assign(:page, page)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "next_button_click",
        # %{"id" => id},
        params,
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    IO.puts("#### next_button_click ###################")
    IO.inspect(params)
    IO.inspect(socket)

    socket =
      socket
      |> assign(:page, socket.assgins.page + 1)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        event,
        # %{"id" => id},
        params,
        socket
      ) do
    # TODO これは雛形です処理を記述すること
    IO.puts("#### handle_event ###################")
    IO.inspect(event)
    IO.inspect(params)
    IO.inspect(socket)

    {:noreply, socket}
  end

  def set_menu_items(false), do: []
  def set_menu_items(_), do: @menu_items

  defp inner_tab(assigns) do
    IO.puts("### inner_tab ###################")
    IO.inspect(assigns)

    ~H"""
    <div class="flex border-b border-brightGray-50">
      <div class="overflow-hidden">
        <ul id="relational_user_tab" class="overflow-hidden flex text-base !text-sm w-[99999px]" >
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
        %{page: 1, page_size: 999}
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

    member_and_users = get_team_member_user_profiles(first_team_id, %{page: 1, page_size: assigns.page_size})

    assigns =
      assigns
      |> assign(:selected_tab, "team")
      |> assign(:inner_tab, inner_tabs)
      |> assign(:inner_selected_tab, first_tab_name)
      |> assign(:user_profiles, member_and_users.user_smalls)
      |> assign(:total_pages, member_and_users.total_pages)
  end

  defp get_team_member_user_profiles(team_id, page_params) do
    page =
      Teams.list_jined_users_and_profiles_by_team_id(
        team_id,
        # TODO タブ内でのページング
        # %{page: 1, page_size: 10}
        page_params
      )

    member_and_users = page.entries
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

    %{user_smalls: member_and_users, total_pages: page.total_pages}
  end
end
