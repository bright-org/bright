defmodule BrightWeb.SearchLive.SkillSearchComponent do
  use BrightWeb, :live_component

  alias BrightWeb.BrightCoreComponents, as: BrightCore
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
      <BrightCore.flash_group flash={@modal_flash} />
      <div class="bg-zinc-50/90 fixed inset-0 transition-opacity" />
      <div class="fixed inset-0 overflow-y-auto">
        <section
          id="user_search" class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[1000px]"
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
            id="user_search"
            module={UserSearchComponent}
            current_user={@current_user}
            />
          </.tab>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:tabs, @tabs)
    |> assign(:selected_tab, @default_tab)
    |> assign(:modal_flash, Map.get(assigns, :modal_flash, %{}))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => tab_name}, socket) do
    socket
    |> assign(:selected_tab, tab_name)
    |> then(&{:noreply, &1})
  end
end
