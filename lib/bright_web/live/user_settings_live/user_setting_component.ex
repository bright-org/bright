defmodule BrightWeb.UserSettingComponent do
  use BrightWeb, :live_component
  alias BrightWeb.UserSettingsLive
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
    <section class="absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[800px] z-20" id="personal_settings">
      <.link
        href="/users/log_out"
        method="delete"
        class="block px-4 py-0 dark:hover:bg-gray-600 dark:hover:text-white"
        >
        ログアウトする
      </.link>

      <.tab
        id="user_settings"
        tabs={@tabs}
        hidden_footer={true}
        selected_tab={@selected_tab}
        target={@myself}
      >
        <ul id="account_settings_content">
          <.live_component
            module={@module}
            id={"user_settings"}
            action={:edit}
            user={@current_user}
          />
        </ul>
      </.tab>
    </section>
    """
  end

  @impl true
  def update(%{action: action} = assigns, socket) do
    socket
    |> assign(assigns)
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
    |> push_patch(to: "/mypage/settings/#{tab_name}")
    |> then(&{:noreply, &1})
  end
end
