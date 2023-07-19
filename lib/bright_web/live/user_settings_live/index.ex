defmodule BrightWeb.UserSettingsLive.Index do
  alias BrightWeb.UserSettingsLive
  use BrightWeb, :live_view
  import BrightWeb.TabComponents
  alias UserSettingsLive.Util

  @tab_info %{
    "一般" => {"", UserSettingsLive.GeneralSettingComponent},
    "メール・パスワード" => {"auth", UserSettingsLive.AuthSettingComponent},
    "SNS連携" => {"sns", UserSettingsLive.SnsSettingComponent},
    "求職" => {"job", UserSettingsLive.JobSettingComponent}
  }

  @impl true
  def render(assigns) do
    ~H"""
    <div class="m-8">
      <h5>ユーザー設定</h5>
      <.tab
      id="user_settings"
      tabs={["一般", "メール・パスワード", "SNS連携", "求職"]}
      hidden_footer={true}
      selected_tab={@selected_tab}
      >
      <.live_component
        module={@module}
        id={"user"}
        title={"page"}
        patch={~p"/users/settings/#{@path}"}
      />
      </.tab>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {path, module} = Map.get(@tab_info, "一般")

    socket
    |> assign(:selected_tab, "一般")
    |> assign(:module, module)
    |> assign(:path, path)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"tab_name" => tab_name},
        socket
      ) do
    {path, module} = Map.get(@tab_info, tab_name)

    socket
    |> assign(:selected_tab, tab_name)
    |> assign(:module, module)
    |> assign(:path, path)
    |> then(&{:noreply, &1})
  end
end
