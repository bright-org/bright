defmodule BrightWeb.Admin.DraftSkillClassLive.Show do
  use BrightWeb, :live_view

  alias Bright.DraftSkillPanels
  alias Bright.DraftSkillUnits
  alias Bright.Utils.SkillsTableStructure

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    skill_class = DraftSkillPanels.get_draft_skill_class!(id)
    skill_panel = DraftSkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    {:noreply,
     socket
     |> assign(:skill_panel, skill_panel)
     |> assign(:skill_class, skill_class)
     |> assign_table_structure()}
  end

  defp assign_table_structure(socket) do
    %{skill_class: skill_class} = socket.assigns

    skill_units =
      Ecto.assoc(skill_class, :draft_skill_units)
      |> DraftSkillUnits.list_draft_skill_units()
      |> Bright.Repo.preload([draft_skill_categories: [:draft_skills]])

    table_structure = SkillsTableStructure.build(skill_units)

    assign(socket, :table_structure, table_structure)
  end
end
