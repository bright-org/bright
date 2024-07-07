defmodule BrightWeb.Share.GraphLive.Graphs do
  use BrightWeb, :live_view

  alias BrightWeb.SkillPanelLive.SkillPanelHelper
  alias BrightWeb.Share.Helper, as: ShareHelper
  alias BrightWeb.LayoutComponents
  alias BrightWeb.ProfileComponents
  alias Bright.SkillPanels
  alias Bright.Accounts
  alias Bright.Repo

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:select_label, "now")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> assign_by_params(params)
    |> SkillPanelHelper.assign_skill_score_dict()
    |> SkillPanelHelper.assign_counter()
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info(
        %{event_name: "timeline_bar_button_click", params: %{"id" => "myself", "date" => date}},
        socket
      ) do
    {:noreply, assign(socket, :select_label, date)}
  end

  defp assign_by_params(socket, params) do
    ShareHelper.decode_share_graph_token!(params)
    |> then(fn %{user_id: user_id, skill_class_id: skill_class_id} ->
      assign_by_user_id_and_skill_class(socket, user_id, skill_class_id)
    end)
  end

  defp assign_by_user_id_and_skill_class(socket, user_id, skill_class_id) do
    display_user = Accounts.get_user!(user_id)

    skill_class =
      SkillPanels.get_skill_class!(skill_class_id)
      |> Repo.preload(skill_class_scores: Ecto.assoc(display_user, :skill_class_scores))
      |> Repo.preload(:skill_panel)

    skill_panel = skill_class.skill_panel
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:me, false)
    |> assign(:anonymous, true)
    |> assign(:display_user, display_user)
    |> assign(:skill_panel, skill_panel)
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end
end
