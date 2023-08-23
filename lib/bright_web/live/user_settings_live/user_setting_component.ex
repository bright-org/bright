defmodule BrightWeb.UserSettingsLive.UserSettingComponent do
  use BrightWeb, :live_component
  alias BrightWeb.UserSettingsLive
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.TabComponents

  @tab_module %{
    "general" => UserSettingsLive.GeneralSettingComponent,
    "auth" => UserSettingsLive.AuthSettingComponent,
    "sns" => UserSettingsLive.SnsSettingComponent,
    "job" => UserSettingsLive.JobSettingComponent
    # NOTE: α版では通知機能はなし
    # "notification" => UserSettingsLive.NotificationSettingComponent　
  }
  @tabs [
    {"general", "一般"},
    {"auth", "メール・パスワード"},
    {"sns", "SNS連携"},
    {"job", "求職"}
    # NOTE: α版では通知機能はなし
    # {"notification", "通知"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="personal_setting_modal" class="hidden">
      <BrightCore.flash_group flash={@modal_flash} />
      <div class="bg-zinc-50/90 fixed inset-0 transition-opacity" />
      <div class="fixed inset-0 overflow-y-auto">
        <section
          id="personal_settings" class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[800px] z-20"
          phx-click-away={JS.hide(to: "#personal_setting_modal")}
        >
          <div class="w-full mb-4">
          <button class="absolute top-4 right-8">
            <span
              class="material-icons text-white !text-sm bg-base rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
              phx-click={JS.hide(to: "#personal_setting_modal")}
            >close</span>
          </button>
          </div>
          <.tab
            id="user_settings"
            tabs={@tabs}
            hidden_footer={true}
            selected_tab={@selected_tab}
            target={@myself}
          >
            <.live_component
              module={@module}
              id={"user_settings"}
              user={@current_user}
              action={:edit}
            />
          </.tab>
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{action: action} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:tabs, @tabs)
    |> assign(:selected_tab, action)
    |> assign(:module, Map.get(@tab_module, action))
    |> assign(:modal_flash, Map.get(assigns, :modal_flash, %{}))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => tab_name}, socket) do
    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:module, Map.get(@tab_module, tab_name))
    |> assign(:action, tab_name)
    |> then(&{:noreply, &1})
  end
end
