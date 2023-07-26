defmodule BrightWeb.UserSettingsLive.Index do
  alias BrightWeb.UserSettingsLive
  use BrightWeb, :live_view
  import BrightWeb.TabComponents

  @tab_module %{
    general: UserSettingsLive.GeneralSettingComponent,
    auth: UserSettingsLive.AuthSettingComponent,
    sns: UserSettingsLive.SnsSettingComponent,
    job: UserSettingsLive.JobSettingComponent,
    notification: UserSettingsLive.NotificationSettingComponent
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
    <section class="bg-white min-h-[600px] p-4 shadow text-sm top-[60px] w-[800px] z-20" id="personal_settings">
      <.tab
        id="user_settings"
        tabs={@tabs}
        hidden_footer={true}
        selected_tab={@selected_tab}
      >
        <.live_component
          module={@module}
          id={"user_settings"}
          user={@current_user}
        />
      </.tab>
    </section>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{live_action: action}} = socket) do
    socket
    |> assign(:page_title, "個人設定")
    |> assign(:tabs, @tabs)
    |> assign(:selected_tab, to_string(action))
    |> assign(:module, Map.get(@tab_module, action))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("tab_click", %{"tab_name" => tab_name}, socket) do
    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:module, Map.get(@tab_module, String.to_atom(tab_name)))
    |> push_patch(to: "/settings/#{tab_name}")
    |> then(&{:noreply, &1})
  end
end
