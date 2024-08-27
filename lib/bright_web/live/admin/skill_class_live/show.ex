defmodule BrightWeb.Admin.SkillClassLive.Show do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillExams
  alias Bright.SkillReferences
  alias Bright.Utils.SkillsTableStructure
  alias BrightWeb.Admin.SkillClassLive.SkillFormComponent

  def mount(_params, _session, socket) do
    # base_loadは開発都合でいれているフラグです。patch移動時にエラーがでるとアサインが整わない状態になり開発に手がかかるため入れていますが効率のみ求めるなら不要です
    {:ok, assign(socket, :base_load, false)}
  end

  def handle_params(params, _url, socket) do
    assign_on_action(socket.assigns.live_action, params, socket)
  end

  defp assign_on_action(:show, params, socket) do
    {:noreply,
     socket
     |> assign(:base_load, false)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:edit_skill, %{"skill_id" => skill_id} = params, socket) do
    skill = SkillUnits.get_skill!(skill_id)

    {:noreply,
     socket
     |> assign(:skill, skill)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:show_reference, %{"skill_id" => skill_id} = params, socket) do
    skill = SkillUnits.get_skill!(skill_id)
    skill_reference = SkillReferences.get_skill_reference_by!(skill_id: skill.id)

    {:noreply,
     socket
     |> assign(:skill, skill)
     |> assign(:skill_reference, skill_reference)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:show_exam, %{"skill_id" => skill_id} = params, socket) do
    skill = SkillUnits.get_skill!(skill_id)
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: skill.id)

    {:noreply,
     socket
     |> assign(:skill, skill)
     |> assign(:skill_exam, skill_exam)
     |> assign_base_page_attrs(params)}
  end

  defp assign_base_page_attrs(%{assigns: %{base_load: false}} = socket, %{"id" => id}) do
    skill_class = SkillPanels.get_skill_class!(id)
    skill_panel = SkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    socket
    |> assign(:skill_panel, skill_panel)
    |> assign(:skill_class, skill_class)
    |> assign_table_structure()
    |> assign(:page_path, ~p"/admin/skill_classes/#{skill_class}")
    |> assign(:base_load, true)
  end

  defp assign_base_page_attrs(socket, _params), do: socket

  defp assign_table_structure(socket) do
    %{skill_class: skill_class} = socket.assigns

    skill_units =
      SkillUnits.list_skill_units_on_class(skill_class)
      |> Bright.Repo.preload(
        skill_categories: [skills: [:skill_reference, :skill_exam]],
        skill_classes: [:skill_panel]
      )

    table_structure = SkillsTableStructure.build(skill_units)

    assign(socket, :table_structure, table_structure)
  end

  defp list_shared_skill_classes(skill_unit, skill_class) do
    skill_unit.skill_classes
    |> Enum.filter(&(&1.id != skill_class.id))
  end
end
