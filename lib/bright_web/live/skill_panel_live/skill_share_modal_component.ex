defmodule BrightWeb.SkillPanelLive.SkillShareModalComponent do
  @moduledoc """
  スキルパネル取得シェアする際に表示するモーダル
  """

  use BrightWeb, :live_component
  alias BrightWeb.SnsComponents

  import BrightWeb.BrightModalComponents
  import BrightWeb.BrightGraphComponents
  import BrightWeb.GuideMessageComponents


  # id={@id}  id={"#{@id}_modal"}
  def render(assigns) do
    ~H"""
    <div >
      <.bright_modal
        id="test"
        :if={true}
        on_cancel={JS.push("close", target: @myself)}
        show
      >
        <.header>スキルパネル取得</.header>

        <div class="my-4 min-w-80">
          <div class="flex flex-col gap-y-2">
            <p>「XXXスキル」をスタートしました！</p>
            <p>まずは平均を目指しましょう</p>
            <.triangle_graph data={%{normal: 50, beginner: 20, skilled: 30}} id="triangle-graph-single-data3"/>

          </div>
        </div>

        <SnsComponents.sns_share_button_group share_graph_url={"test"} skill_panel={"test"}  />

        <.first_card_skills_edit_message />
      </.bright_modal>
    </div>
    """
  end

  def update(%{open: true} = assigns, socket) do
    IO.inspect(assigns)
    {:ok, socket}
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
