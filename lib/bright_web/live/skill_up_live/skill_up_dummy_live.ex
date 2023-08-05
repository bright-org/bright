defmodule BrightWeb.SkillUpDummyLive do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.UserSkillPanels

  @impl true
  def render(assigns) do
    ~H"""
    <div class="m-12 max-w-[820px]">
      <.table
        id="skill_panels"
        rows={@streams.skill_panels}
      >
        <:col :let={{_id, skill_panel}} label="Name"><%= skill_panel.name %></:col>
        <:action :let={{_id, skill_panel}}>
          <%= if Enum.member?(@exists_panel, skill_panel.id) do %>
          <p>取得済み</p>
          <% else %>
          <.button
            phx-click={JS.push("select_skill_panel", value: %{id: skill_panel.id, name: skill_panel.name})}
          >
            このスキルパネルを選択
          </.button>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    socket
    |> stream(:skill_panels, SkillPanels.list_skill_panels())
    |> assign(:exists_panel, UserSkillPanels.list_user_skill_panels_dev(user.id))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "スキルパネル一覧")
  end

  @impl true
  def handle_event("select_skill_panel", %{"id" => skill_panel_id, "name" => name}, socket) do
    UserSkillPanels.create_user_skill_panel(%{
      user_id: socket.assigns.current_user.id,
      skill_panel_id: skill_panel_id
    })

    socket
    |> put_flash(:info, "スキルパネル:#{name}を取得しました")
    |> push_navigate(to: "/panels/#{skill_panel_id}/graph")
    |> then(&{:noreply, &1})
  end
end
