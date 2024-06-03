defmodule BrightWeb.Admin.DraftSkillClassLive.Show do
  use BrightWeb, :live_view

  alias Bright.DraftSkillPanels
  alias Bright.DraftSkillUnits
  alias Bright.Utils.SkillsTableStructure

  alias BrightWeb.Admin.DraftSkillClassLive.{
    SkillFormComponent,
    SkillClassFormComponent
  }

  def mount(_params, _session, socket) do
    # base_loadは開発都合でいれているフラグです。
    # patch移動時にエラーがでるとアサインが整わない状態になり開発に手がかかるため対応しています。
    {:ok, assign(socket, :base_load, false)}
  end

  def handle_params(params, _url, socket) do
    assign_on_action(socket.assigns.live_action, params, socket)
  end

  def assign_on_action(:show, params, socket) do
    {:noreply,
      socket
      |> assign(:base_load, false)
      |> assign_base_page_attrs(params)}
  end

  def assign_on_action(:edit_skill_class, params, socket) do
    {:noreply, assign_base_page_attrs(socket, params)}
  end

  def assign_on_action(:new_skill, %{"category" => category_id} = params, socket) do
    skill = %DraftSkillUnits.DraftSkill{draft_skill_category_id: category_id}

    {:noreply,
      socket
      |> assign(:skill, skill)
      |> assign_base_page_attrs(params)}
  end

  def assign_on_action(:edit_skill, %{"skill_id" => skill_id} = params, socket) do
    skill = DraftSkillUnits.get_draft_skill!(skill_id)
    {:noreply,
      socket
      |> assign(:skill, skill)
      |> assign_base_page_attrs(params)}
  end

  defp assign_base_page_attrs(%{assigns: %{base_load: false}} = socket, %{"id" => id}) do
    skill_class = DraftSkillPanels.get_draft_skill_class!(id)
    skill_panel = DraftSkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    socket
    |> assign(:skill_panel, skill_panel)
    |> assign(:skill_class, skill_class)
    |> assign_table_structure()
    |> assign(:page_path, ~p"/admin/draft_skill_classes/#{skill_class}")
    |> assign(:base_load, true)
  end

  defp assign_base_page_attrs(socket, _params), do: socket

  defp assign_table_structure(socket) do
    %{skill_class: skill_class} = socket.assigns

    skill_units =
      Ecto.assoc(skill_class, :draft_skill_units)
      |> DraftSkillUnits.list_draft_skill_units()
      |> Bright.Repo.preload(draft_skill_categories: [:draft_skills], draft_skill_classes: [:skill_panel])

    table_structure = SkillsTableStructure.build(skill_units)

    assign(socket, :table_structure, table_structure)
  end

  defp list_shared_skill_classes(skill_unit, skill_class) do
    skill_unit.draft_skill_classes
    |> Enum.filter(& &1.id != skill_class.id)
  end
end
