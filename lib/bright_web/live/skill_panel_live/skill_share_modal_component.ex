defmodule BrightWeb.SkillPanelLive.SkillShareModalComponent do
  @moduledoc """
  スキルパネル取得シェアする際に表示するモーダル
  """

  use BrightWeb, :live_component
  alias BrightWeb.SnsComponents

  import BrightWeb.BrightModalComponents
  import BrightWeb.BrightGraphComponents
  import BrightWeb.GuideMessageComponents

  def render(assigns) do
    assigns =
      assigns
      |> assign(url: url(~p"/get_skill_panel/#{assigns.skill_panel.id}"))

    ~H"""
    <div id={@id}>
      <.bright_modal
        id={"#{@id}_modal"}
        :if={@open}
        on_cancel={JS.push("close", target: @myself)}
        show
      >
        <.header>スキルパネル取得</.header>

        <div class="my-4 min-w-80">
          <div class="flex flex-col gap-y-2">
            <p>「<%= @data.name %>」をスタートしました！</p>
            <p>まずは平均を目指しましょう</p>
            <.triangle_graph data={@data} id="triangle_graph"/>
          </div>
        </div>
        <SnsComponents.sns_share_button_group share_graph_url={@url} skill_panel={@skill_panel.name} level_text={"start"} />
        <.first_card_skills_edit_message />
      </.bright_modal>
    </div>
    """
  end

  def update(%{open: true} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:open, false)}
  end

  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :open, false)}
  end
end
