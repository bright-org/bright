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
    "notification" => UserSettingsLive.NotificationSettingComponent
  }
  @tabs [
    {"general", "一般"},
    {"auth", "メール・パスワード"},
    {"sns", "SNS連携"},
    {"job", "求職"},
    {"notification", "通知"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <section class="hidden absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[800px] z-20" id="personal_settings">
      <BrightCore.flash_group flash={@modal_flash} />
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
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({_module, {:saved, flash}}, socket) do
    {:noreply, assign(:modal_flash, flash)}
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
