defmodule BrightWeb.TeamSupportLiveComponent do
  @moduledoc """
  採用・育成支援のLiveComponent
  """
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.Accounts.UserNotifier

  import BrightWeb.BrightCoreComponents, only: [action_button: 1]
  import BrightWeb.ProfileComponents
  import BrightWeb.TeamComponents
  import BrightWeb.TabComponents

  alias Bright.UserProfiles
  alias alias Bright.Teams

  @tabs [
    {"supporter_teams", "採用・育成チーム"}
  ]

  @tab "supporter_teams"

  @menu_items []

  @doc """
  Renders a request hr support.

  ## Examples

  """
  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative rounded-sm px-16 py-8">
      <!-- Modal header -->
      <.render_title modal_mode={assigns.modal_mode}/>
      <!-- Modal Body -->
      <div class="pt-8">
        <div id="supportee_block" class="flex mb-1">
          <div
            :if={@modal_mode == "request" || @modal_mode == "requesting" }
            id="supportee_area_left"class="min-w-[580px] pr-10 border-r border-r-brightGray-200 border-dashed"
            >

            <.render_user_search
              :if={@modal_mode == "request"}
              search_word={@search_word}
              phx_target={@myself}
              search_word_error={@search_word_error}
            />

            <.render_supporter_team_card
              :if={@modal_mode == "requesting"}
              tabs={@tabs}
              card={@card}
              phx_target={@myself}
              select_supporter_team_error={@select_supporter_team_error}
            />

          </div>
          <div id="supportee_area_right" class="w-[580px] pl-10 flex flex-col justify-between">
            <div class="item-left mb-5">
              <h5 :if={@modal_mode == "request"}>支援対象チーム</h5>
              <h5 :if={@modal_mode != "request"}>支援対象チーム／依頼ユーザー</h5>
              <div class="bg-brightGray-10 rounded-sm mt-2">
                <.render_supportee_team
                  modal_mode={@modal_mode}
                  request_from_user={@request_from_user}
                  supportee_team={@supportee_team}
                />
                <.render_request_from_user
                  :if={@modal_mode != "request"}
                  request_from_user={@request_from_user}
                />
                </div>
            </div>

            <div class="item-left mb-5">
              <h5 :if={@modal_mode == "request"}>支援依頼先ユーザー</h5>
              <h5 :if={@modal_mode != "request"}>支援担当チーム／確認ユーザー</h5>
              <div class="bg-brightGray-10 rounded-sm mt-2">
                <.render_supporter_team
                  :if={@modal_mode != "request"}
                  supporter_team={@supporter_team}
                />
                <.render_request_to_user
                  request_to_user={@request_to_user}
                />
              </div>
            </div>
          </div>
        </div>
        <div id="bottom_area" class="flex justify-end gap-x-4 pt-3">
          <.render_botton
            modal_mode={@modal_mode}
            phx_target={@myself}
          />
        </div>
      </div>
    </div>
    """
  end

  defp render_botton(%{modal_mode: "request"} = assigns) do
    ~H"""
    <button
      type="submit"
      class="text-sm font-bold px-5 py-3 rounded text-white bg-base"
      phx-click="request_team_support"
      phx-target={@phx_target}
    >
      支援依頼する
    </button>
    """
  end

  defp render_botton(%{modal_mode: "requesting"} = assigns) do
    ~H"""
    <button
      type="submit"
      class="text-sm font-bold px-5 py-3 rounded text-white bg-base"
      phx-click="accept_team_support"
      phx-target={@phx_target}
      >
      チームを支援する
    </button>
    <button
      type="cancel"
      class="text-sm font-bold px-5 py-2 rounded border border-base ml-2.5"
      phx-click="reject_team_support"
      phx-target={@phx_target}
      >
      支援対象チームではない
    </button>
    """
  end

  defp render_botton(%{modal_mode: "supporting"} = assigns) do
    ~H"""
    <button
      class="text-sm font-bold px-5 py-3 rounded text-white bg-attention-600"
      phx-click="end_team_support"
      phx-target={@phx_target}
      data-confirm="支援を終了してよろしいでしょうか？"
      >
      支援を終了する
    </button>
    """
  end

  defp render_title(%{modal_mode: "request"} = assigns) do
    ~H"""
    <h3>
      採用・育成の支援依頼（β）
    </h3>
    """
  end

  defp render_title(%{modal_mode: "requesting"} = assigns) do
    ~H"""
    <h3>
      支援依頼を確認する（β）
    </h3>
    """
  end

  defp render_title(%{modal_mode: "supporting"} = assigns) do
    ~H"""
    <h3>
      支援を終了する
    </h3>
    """
  end

  defp render_supportee_team(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-sm px-3 py-3">
      <label for="supportee_team_name" class="flex items-center ">
        <div>
          <.team_small
            id="team_small_{@supportee_team.id}"
            team_params={convert_team_params_from_team(@supportee_team)}
            row_on_click=""
            on_hover_style=""
          />
        </div>
      </label>
    </div>
    """
  end

  defp render_supporter_team(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-sm px-3 py-3">
      <label for="supportee_team_name" class="flex items-center min-h-[35px]">
        <div :if={is_nil(@supporter_team)}>
          採用・育成を担当するチームを選択してください
        </div>
        <div :if={!is_nil(@supporter_team)}>
          <.team_small
            :if={!is_nil(@supporter_team)}
            id="team_small_{@supporter_team.id}"
            team_params={convert_team_params_from_team(@supporter_team)}
            row_on_click=""
            on_hover_style=""
          />
        </div>
      </label>
    </div>
    """
  end

  defp render_request_from_user(assigns) do
    ~H"""
    <div class="bg-brightGray-10 rounded-sm px-3 py-3">
      <label for="team_name" class="flex items-center ">
        <div
          :if={!is_nil(@request_from_user)}
          class="w-[300px] text-left flex items-center text-base p-2 rounded border border-brightGray-100 bg-white"
        >
        <.profile_mini
            user_name={@request_from_user.name}
            icon_file_path={UserProfiles.icon_url(@request_from_user.user_profile.icon_file_path)}
          />
        </div>
      </label>
    </div>
    """
  end

  defp render_request_to_user(assigns) do
    # @request_to_user
    ~H"""
    <div class="bg-brightGray-10 rounded-sm px-3 py-3">
      <label for="team_name" class="flex items-center min-h-[50px]">
        <div
          :if={!is_nil(@request_to_user)}
          class="w-[300px] text-left flex items-center text-base p-2 rounded border border-brightGray-100 bg-white"
        >
        <.profile_mini
            user_name={@request_to_user.name}
            icon_file_path={UserProfiles.icon_url(@request_to_user.user_profile.icon_file_path)}
          />
        </div>
      </label>
    </div>
    """
  end

  defp render_user_search(assigns) do
    # @search_word
    # @phx_target
    # @search_word_error

    ~H"""
    <div class="flex items-center">
          <form
            id="search_user_form"
            phx-target={@phx_target}
            phx-submit="search_user"
          >
            <p class="pb-2 text-base">
              支援依頼先ユーザーの<span class="font-bold">Brightハンドル名もしくはメールアドレス</span>を検索
            </p>
            <input
              id="search_word"
              name="search_word"
              type="autocomplete"
              placeholder="ハンドル名もしくはメールアドレスを入力してください"
              class="px-5 py-2 border border-brightGray-100 rounded-sm flex-1 w-[390px]"
              phx-change="change_search_user"
              value={@search_word}
            />
            <.action_button type="submit" class="ml-2.5">
              検索
            </.action_button>
          </form>
        </div>
        <div :if={@search_word_error != nil}>
          <p class= "text-error text-xs"><%= Phoenix.HTML.raw(@search_word_error) %></p>
        </div>
    """
  end

  defp render_supporter_team_card(assigns) do
    ~H"""
    <p class="pb-2 text-base">
      <span class="font-bold">採用・育成を担当する</span>チームを選択
    </p>
    <div class="rounded border border-brightGray-100 bg-white">
      <.tab
          id={"supporter-team-card-tab"}
          tabs={@tabs}
          selected_tab={@card.selected_tab}
          page={@card.page_params.page}
          total_pages={@card.total_pages}
          target={@phx_target}
        >
          <div class="pt-3 pb-1 px-6 lg:h-[226px]">
            <ul class="flex gap-y-2 flex-col">
              <%= for team_params <- @card.entries do %>
                <.team_small
                  id={team_params.team_id}
                  team_params={team_params}
                  row_on_click_target={@phx_target}
                />
              <% end %>
            </ul>
          </div>
      </.tab>
    </div>
    <div :if={!is_nil(@select_supporter_team_error)}>
      <p class= "text-error text-xs"><%= Phoenix.HTML.raw(@select_supporter_team_error) %></p>
    </div>
    """
  end

  defp assign_card(socket, "supporter_teams") do
    page =
      Teams.list_joined_supporter_teams_by_user_id(
        socket.assigns.display_user.id,
        socket.assigns.supportee_team.id,
        socket.assigns.card.page_params
      )

    team_params =
      page.entries
      |> convert_team_params_from_team_member_users()

    card = %{
      socket.assigns.card
      | entries: team_params,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  @impl true
  def mount(socket) do
    socket
    |> assign(:request_to_user, nil)
    |> assign(:request_from_user, nil)
    |> assign(:supporter_team, nil)
    |> assign(:supportee_team, nil)
    |> assign(:search_word, nil)
    |> assign(:search_word_error, nil)
    |> assign(:select_supporter_team_error, nil)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(%{modal_mode: "request"} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:search_word, nil)
     |> assign(:search_word_error, nil)
     |> assign(:request_from_user, assigns.request_from_user)
     |> assign(:supportee_team, assigns.request_target_team)}
  end

  @impl true
  def update(%{modal_mode: "requesting"} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:request_to_user, assigns.display_team_supporter_team.request_to_user)
     |> assign(:request_from_user, assigns.display_team_supporter_team.request_from_user)
     |> assign(:supportee_team, assigns.display_team_supporter_team.supportee_team)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param(@tab))
     |> assign_card(@tab)}
  end

  @impl true
  def update(%{modal_mode: "supporting"} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:request_to_user, assigns.display_team_supporter_team.request_to_user)
     |> assign(:request_from_user, assigns.display_team_supporter_team.request_from_user)
     |> assign(:supportee_team, assigns.display_team_supporter_team.supportee_team)
     |> assign(:supporter_team, assigns.display_team_supporter_team.supportee_team)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param(@tab))
     |> assign_card(@tab)}
  end

  @impl true
  def handle_event("change_search_user", %{"search_word" => search_word}, socket) do
    {:noreply, assign(socket, :search_word, search_word)}
  end

  def handle_event("search_user", _params, socket) do
    search_word = socket.assigns.search_word

    socket
    |> validate_search_word(search_word)
    |> validate_search_user(search_word)
    |> assign_request_to_user()
    |> then(&{:noreply, &1})
  end

  def handle_event("request_team_support", _params, socket) do
    if is_nil(socket.assigns.request_to_user) do
      {:noreply,
       socket
       |> assign(search_word_error: "支援依頼先ユーザーを選択してください")}
    else
      {:ok, _team_supporter_team} =
        Teams.request_support_from_suportee_team(
          socket.assigns.request_target_team.id,
          socket.assigns.request_from_user.id,
          socket.assigns.request_to_user.id
        )

      from_user = socket.assigns.request_from_user
      to_user = socket.assigns.request_to_user
      supportee_team = socket.assigns.supportee_team
      url = url(~p"/team_supports")
      UserNotifier.deliver_notify_team_support_request(from_user, to_user, supportee_team, url)

      {:noreply,
       socket
       |> put_flash(:info, "支援依頼を送信しました")
       |> redirect(to: socket.assigns.redirect_path)}
    end
  end

  def handle_event("accept_team_support", _params, socket) do
    if is_nil(socket.assigns.supporter_team) do
      {:noreply,
       socket
       |> assign(:select_supporter_team_error, "採用・育成を担当するチームを選択してください")}
    else
      {:ok, _team_supporter_team} =
        Teams.accept_support_by_supporter_team(
          socket.assigns.display_team_supporter_team,
          socket.assigns.supporter_team.id
        )

      from_user = socket.assigns.request_to_user
      to_user = socket.assigns.request_from_user
      supportee_team = socket.assigns.supportee_team

      UserNotifier.deliver_accept_team_support_request(
        from_user,
        to_user,
        supportee_team
      )

      {:noreply,
       socket
       |> put_flash(:info, "支援依頼を承認しました")
       |> redirect(to: socket.assigns.redirect_path)}
    end
  end

  def handle_event("reject_team_support", _params, socket) do
    {:ok, _team_supporter_team} =
      Teams.reject_support_by_supporter_team(socket.assigns.display_team_supporter_team)

    from_user = socket.assigns.request_to_user
    to_user = socket.assigns.request_from_user
    supportee_team = socket.assigns.supportee_team

    UserNotifier.deliver_reject_team_support_request(
      from_user,
      to_user,
      supportee_team
    )

    {:noreply,
     socket
     |> put_flash(:info, "支援依頼を非承認にしました")
     |> redirect(to: socket.assigns.redirect_path)}
  end

  def handle_event("end_team_support", _params, socket) do
    {:ok, _team_supporter_team} =
      Teams.end_support_by_supporter_team(socket.assigns.display_team_supporter_team)

    # TODO 管理者にサポート終了メールを送る？
    # from_user = socket.assigns.current_user
    # to_user = socket.assigns.request_from_user
    # supportee_team = socket.assigns.supportee_team
    # UserNotifier.deliver_reject_team_support_request(
    #  from_user,
    #  to_user,
    #  supportee_team
    # )

    {:noreply,
     socket
     |> put_flash(:info, "支援を終了しました")
     |> redirect(to: socket.assigns.redirect_path)}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => _id, "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page

    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  def handle_event("on_card_row_click", %{"team_id" => team_id}, socket) do
    if Teams.is_supporting_same_team?(socket.assigns.supportee_team.id, team_id) do
      {:noreply,
       socket
       |> assign(:select_supporter_team_error, "選択した採用・育成チームは既に同じチームを支援中です")}
    else
      team = Teams.get_team!(team_id)

      {:noreply,
       socket
       |> assign(:supporter_team, team)
       |> assign(:select_supporter_team_error, nil)}
    end
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      entries: [],
      page_params: %{page: page, page_size: 15},
      total_entries: 0,
      total_pages: 0,
      menu_items: @menu_items
    }
  end

  defp card_view(socket, tab_name, page) do
    card = create_card_param(page)

    socket
    |> assign(:card, card)
    |> assign_card(tab_name)
    |> then(&{:noreply, &1})
  end

  # 検索ワードのバリデーション
  defp validate_search_word(socket, search_word) do
    if is_nil(search_word) || search_word == "" do
      {:error, assign(socket, search_word_error: "検索条件を入力してください")}
    else
      {:ok, socket}
    end
  end

  # 検索結果のバリデーション
  defp validate_search_user({:error, socket}, _search_word), do: {:error, socket}

  defp validate_search_user({:ok, socket}, search_word) do
    user = Accounts.get_user_by_name_or_email(search_word)

    if is_nil(user) do
      {:error, assign(socket, :search_word_error, "該当のユーザーが見つかりませんでした")}

      # TODO 支援依頼先のユーザーのバリデーション条件
      # HRチームの管理者であることをチェックするか？
    else
      {:ok, socket, user}
    end
  end

  defp assign_request_to_user({:error, socket}) do
    socket
    |> assign(:request_to_user, nil)
  end

  defp assign_request_to_user({:ok, socket, user}) do
    socket
    |> assign(:request_to_user, user)
    |> assign(:search_word, nil)
    |> assign(:search_word_error, nil)
  end
end
