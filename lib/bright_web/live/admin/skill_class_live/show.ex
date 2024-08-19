defmodule BrightWeb.Admin.SkillClassLive.Show do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.Utils.SkillsTableStructure

  alias BrightWeb.Admin.SkillClassLive.{
    SkillClassFormComponent,
    SkillUnitFormComponent,
    SkillUnitAddFormComponent,
    SkillCategoryFormComponent,
    SkillCategoryReplaceFormComponent,
    SkillFormComponent,
    SkillReplaceFormComponent
  }

  def mount(_params, _session, socket) do
    # base_loadは開発都合でいれているフラグです。patch移動時にエラーがでるとアサインが整わない状態になり開発に手がかかるため入れていますが効率のみ求めるなら不要です
    {:ok, assign(socket, :base_load, false)}
  end

  def handle_params(params, _url, socket) do
    assign_on_action(socket.assigns.live_action, params, socket)
  end

  def handle_event("position_up_skill_unit", %{"row" => row}, socket) do
    %{table_structure: table_structure, skill_class: skill_class} = socket.assigns
    index = String.to_integer(row) - 1
    replace_skill_unit(table_structure, skill_class, index, :up)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  def handle_event("position_down_skill_unit", %{"row" => row}, socket) do
    %{table_structure: table_structure, skill_class: skill_class} = socket.assigns
    index = String.to_integer(row) - 1
    replace_skill_unit(table_structure, skill_class, index, :down)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  def handle_event("position_up_skill_category", %{"row" => row}, socket) do
    %{table_structure: table_structure} = socket.assigns
    index = String.to_integer(row) - 1
    [_, %{skill_category: skill_category_from}, _] = Enum.at(table_structure, index)

    [_, %{skill_category: skill_category_to}, _] =
      find_previous_structure_data(table_structure, 1, index - 1)

    SkillUnits.replace_position(skill_category_from, skill_category_to)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  def handle_event("position_down_skill_category", %{"row" => row}, socket) do
    %{table_structure: table_structure} = socket.assigns
    index = String.to_integer(row) - 1
    [_, %{skill_category: skill_category_from}, _] = Enum.at(table_structure, index)

    [_, %{skill_category: skill_category_to}, _] =
      find_next_structure_data(table_structure, 1, index + 1)

    SkillUnits.replace_position(skill_category_from, skill_category_to)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  def handle_event("position_up_skill", %{"row" => row}, socket) do
    %{table_structure: table_structure} = socket.assigns
    index = String.to_integer(row) - 1
    [_, _, %{skill: skill_from}] = Enum.at(table_structure, index)
    [_, _, %{skill: skill_to}] = Enum.at(table_structure, index - 1)
    SkillUnits.replace_position(skill_from, skill_to)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  def handle_event("position_down_skill", %{"row" => row}, socket) do
    %{table_structure: table_structure} = socket.assigns
    index = String.to_integer(row) - 1
    [_, _, %{skill: skill_from}] = Enum.at(table_structure, index)
    [_, _, %{skill: skill_to}] = Enum.at(table_structure, index + 1)
    SkillUnits.replace_position(skill_from, skill_to)

    {:noreply,
     socket
     |> put_flash(:info, "並び替えました")
     |> assign_table_structure()}
  end

  defp assign_on_action(:show, params, socket) do
    {:noreply,
     socket
     |> assign(:base_load, false)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:edit_skill_class, params, socket) do
    {:noreply, assign_base_page_attrs(socket, params)}
  end

  defp assign_on_action(:new_skill_unit, params, socket) do
    skill_unit = %SkillUnits.SkillUnit{}

    {:noreply,
     socket
     |> assign_base_page_attrs(params)
     |> assign(:skill_unit, skill_unit)}
  end

  defp assign_on_action(:add_skill_unit, params, socket) do
    {:noreply,
     socket
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:edit_skill_unit, %{"skill_unit_id" => unit_id} = params, socket) do
    skill_unit = SkillUnits.get_skill_unit!(unit_id)

    {:noreply,
     socket
     |> assign(:skill_unit, skill_unit)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:new_skill_category, %{"unit" => unit_id} = params, socket) do
    skill_category = %SkillUnits.SkillCategory{skill_unit_id: unit_id}

    {:noreply,
     socket
     |> assign(:skill_category, skill_category)
     |> assign(:single_row_data?, false)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(
         :edit_skill_category,
         %{"skill_category_id" => category_id} = params,
         socket
       ) do
    skill_category = SkillUnits.get_skill_category!(category_id)
    single_row_data? = params["single"] == "true"

    {:noreply,
     socket
     |> assign(:skill_category, skill_category)
     |> assign(:single_row_data?, single_row_data?)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(
         :replace_skill_category,
         %{"skill_category_id" => category_id} = params,
         socket
       ) do
    skill_category = SkillUnits.get_skill_category!(category_id)

    {:noreply,
     socket
     |> assign(:skill_category, skill_category)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:new_skill, %{"category" => category_id} = params, socket) do
    skill = %SkillUnits.Skill{skill_category_id: category_id}

    {:noreply,
     socket
     |> assign(:skill, skill)
     |> assign(:single_row_data?, false)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:edit_skill, %{"skill_id" => skill_id} = params, socket) do
    skill = SkillUnits.get_skill!(skill_id)
    single_row_data? = params["single"] == "true"

    {:noreply,
     socket
     |> assign(:skill, skill)
     |> assign(:single_row_data?, single_row_data?)
     |> assign_base_page_attrs(params)}
  end

  defp assign_on_action(:replace_skill, %{"skill_id" => skill_id} = params, socket) do
    skill = SkillUnits.get_skill!(skill_id)

    {:noreply,
     socket
     |> assign(:skill, skill)
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
        skill_categories: [:skills],
        skill_classes: [:skill_panel]
      )

    table_structure = SkillsTableStructure.build(skill_units)

    assign(socket, :table_structure, table_structure)
  end

  defp list_shared_skill_classes(skill_unit, skill_class) do
    skill_unit.skill_classes
    |> Enum.filter(&(&1.id != skill_class.id))
  end

  defp list_skill_categories_on_skill_class(table_structure) do
    table_structure
    |> Enum.map(fn
      [_, nil, _] -> nil
      [_, col2, _] -> col2.skill_category
    end)
    |> Enum.filter(& &1)
  end

  defp replace_skill_unit(table_structure, skill_class, index, direction) do
    [%{skill_unit: skill_unit_1}, _, _] = Enum.at(table_structure, index)

    [%{skill_unit: skill_unit_2}, _, _] =
      case direction do
        :up ->
          find_previous_structure_data(table_structure, 0, index - 1)

        :down ->
          find_next_structure_data(table_structure, 0, index + 1)
      end

    skill_class_unit_1 = get_skill_class_unit(skill_class, skill_unit_1)
    skill_class_unit_2 = get_skill_class_unit(skill_class, skill_unit_2)

    SkillUnits.replace_position(skill_class_unit_1, skill_class_unit_2)
  end

  defp get_skill_class_unit(skill_class, skill_unit) do
    SkillUnits.get_skill_class_unit_by(
      skill_class_id: skill_class.id,
      skill_unit_id: skill_unit.id
    )
  end

  defp find_previous_structure_data(table_structure, focus_col, start_row) do
    # 入れ替えのために、入れ替え先データをテーブル構造から探す処理
    table_structure
    |> Enum.slice(0..start_row//1)
    |> Enum.reverse()
    |> Enum.find(&Enum.at(&1, focus_col))
  end

  defp find_next_structure_data(table_structure, focus_col, start_row) do
    # 入れ替えのために、入れ替え先データをテーブル構造から探す処理
    table_structure
    |> Enum.slice(start_row..-1//1)
    |> Enum.find(&Enum.at(&1, focus_col))
  end

  defp single_row_data?(col) do
    # 単一データを動かすと構造が消えてエラーになるため画面操作を制御する
    Map.get(col, :first) && Map.get(col, :last)
  end
end
