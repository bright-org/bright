defmodule BrightWeb.Share.GraphLive.Graphs do
  use BrightWeb, :live_view

  alias BrightWeb.UserSkillClassCrypto
  alias BrightWeb.SkillPanelLive.SkillPanelHelper
  alias BrightWeb.LayoutComponents
  alias BrightWeb.ProfileComponents

  @impl true
  def mount(params, _session, socket) do
    socket
    |> UserSkillClassCrypto.assign_from_encrypted_user_id_and_skill_class_id(params)
    |> assign(:select_label, "now")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> SkillPanelHelper.assign_skill_score_dict()
     |> SkillPanelHelper.assign_counter()}
  end

  @impl true
  def handle_info(
        %{event_name: "timeline_bar_button_click", params: %{"id" => "myself", "date" => date}},
        socket
      ) do
    {:noreply, assign(socket, :select_label, date)}
  end
end
