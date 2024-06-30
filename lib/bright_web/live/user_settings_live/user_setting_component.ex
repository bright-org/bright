defmodule BrightWeb.UserSettingsLive.UserSettingComponent do
  use BrightWeb, :live_component
  alias BrightWeb.UserSettingsLive
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  import BrightWeb.TabComponents

  @tab_module %{
    "general" => UserSettingsLive.GeneralSettingComponent,
    "auth" => UserSettingsLive.AuthSettingComponent,
    "sns" => UserSettingsLive.SnsSettingComponent,
    "job" => UserSettingsLive.JobSettingComponent,
    "plan" => UserSettingsLive.CurrentSubscriptionPlanComponent
    # NOTE: α版では通知機能はなし
    # "notification" => UserSettingsLive.NotificationSettingComponent　
  }
  @tabs [
    {"general", "一般"},
    {"auth", "メール・パスワード"},
    {"sns", "SNS連携"},
    {"job", "働く際の希望"},
    {"plan", "利用プラン"}
    # NOTE: α版では通知機能はなし
    # {"notification", "通知"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div id="personal_setting_modal" class="hidden">
      <BrightCore.flash_group flash={@modal_flash} />
      <div class="bg-pureGray-600/90 fixed inset-0 transition-opacity z-[55]" />
      <div class="fixed inset-0 overflow-y-auto z-[60]">
        <section
          id="personal_settings" class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-full lg:w-[800px] z-20"
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
            header_rest="overflow-x-auto whitespace-nowrap scrollbar-hide"
            item_rest="px-4 sm:px-0"
          >
            <.live_component
              module={@module}
              id={"user_settings"}
              user={@current_user}
              action={:edit}
              current_request_path={@current_request_path}
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
    |> assign(:modal_flash, %{})
    |> then(&{:noreply, &1})
  end
end
