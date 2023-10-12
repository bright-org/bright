defmodule BrightWeb.SearchLive.SkillSearchComponent do
  use BrightWeb, :live_component

  alias Bright.RecruitmentStockUsers
  alias BrightWeb.SearchLive.UserSearchComponent
  import BrightWeb.TabComponents

  @tabs [
    {"user", "ユーザー検索"}
    # αでは落とす
    # {"team", "チーム検索"}
  ]
  @default_tab "user"

  @impl true
  def render(assigns) do
    ~H"""
    <div id="skill_search_modal" class="hidden">
      <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-20" />
      <div class="fixed inset-0 overflow-y-auto z-50">
        <section
          id="user_search" class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[1024px]"
          phx-click-away={JS.hide(to: "#skill_search_modal")}
        >
          <div class="w-full mb-4">
          <button class="absolute top-4 right-8">
            <span
              class="material-icons text-white !text-sm bg-base rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
              phx-click={JS.hide(to: "#skill_search_modal")}
            >close</span>
          </button>
          </div>
          <.tab
            id="skill_search_tab"
            tabs={@tabs}
            hidden_footer={true}
            selected_tab={@selected_tab}
            target={@myself}
          >
            <.live_component
              id="user_search_tab"
              module={UserSearchComponent}
              current_user={@current_user}
              stock_user_ids={@stock_user_ids}
            />
          </.tab>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{current_user: user} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:tabs, @tabs)
    |> assign(:selected_tab, @default_tab)
    |> assign(:stock_user_ids, RecruitmentStockUsers.list_stock_user_ids(user.id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => tab_name}, socket) do
    socket
    |> assign(:selected_tab, tab_name)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "stock",
        %{"params" => params},
        %{assigns: %{current_user: user}} = socket
      ) do
    Map.put(params, "recruiter_id", user.id)
    |> RecruitmentStockUsers.create_recruitment_stock_user()

    {:noreply,
     assign(socket, :stock_user_ids, RecruitmentStockUsers.list_stock_user_ids(user.id))}
  end
end
