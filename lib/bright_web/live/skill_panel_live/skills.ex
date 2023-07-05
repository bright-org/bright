defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.SkillUnits

  @impl true
  def mount(params, _session, socket) do
    skill_panel =
      SkillPanels.get_skill_panel!(params["skill_panel_id"])
      |> Bright.Repo.preload([:skill_classes])

    {:ok,
     socket
     |> assign(:skill_panel, skill_panel)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skill_class(params["class"])
     |> assign_skill_units()}
  end

  defp assign_skill_class(socket, nil), do: assign_skill_class(socket, "1")

  defp assign_skill_class(socket, rank) do
    rank = String.to_integer(rank)
    skill_classes = socket.assigns.skill_panel.skill_classes
    skill_class =
      skill_classes
      |> Enum.find(& &1.rank == rank)
      |> Kernel.||(List.last(skill_classes))

    socket
    |> assign(:skill_class, skill_class)
  end

  defp assign_skill_units(socket) do
    # query chainを作るか専用の関数を作るか悩んだため、後で見直し
    import Ecto.Query, only: [preload: 2]

    skill_units =
      Ecto.assoc(socket.assigns.skill_class, :skill_units)
      |> preload(skill_categories: [:skills])
      |> SkillUnits.list_skill_units()

    socket
    |> assign(skill_units: skill_units)
  end

  defp build_table_structure(skill_units) do
    # スキルユニット～スキルの構造をテーブル表示で扱う形式に変換
    #
    # 出力サンプル:
    # [
    #   [%{size: 5, skill_unit: %SkillUnit{}}, %{size: 2, skill_category: %SkillCategory{}}, %{skill: %Skill{}}],
    #   [nil, nil, %{skill: %Skill{}}],
    #   [nil, %{size: 3, skill_category: %SkillCategory{}}, %{skill: %Skill{}}],
    #   [nil, nil, %{skill: %Skill{}}],
    #   [nil, nil, %{skill: %Skill{}}]
    # ]

    skill_units
    |> Enum.flat_map(fn skill_unit ->
      skill_category_items =
        skill_unit.skill_categories
        |> Enum.flat_map(&build_skill_category_table_structure/1)

      build_skill_unit_table_structure(skill_unit, skill_category_items)
    end)
  end

  defp build_skill_category_table_structure(skill_category) do
    size = length(skill_category.skills)
    skill_category_item = %{size: size, skill_category: skill_category}

    skill_category.skills
    |> Enum.with_index()
    |> Enum.map(fn
      {skill, 0} -> [skill_category_item] ++ [%{skill: skill}]
      {skill, _i} -> [nil] ++ [%{skill: skill}]
    end)
  end

  defp build_skill_unit_table_structure(skill_unit, skill_category_items) do
    size =
      skill_category_items
      |> Enum.reduce(0, fn
        [nil, _], acc -> acc
        [%{size: size}, _], acc -> acc + size
      end)

    skill_unit_item = %{size: size, skill_unit: skill_unit}

    skill_category_items
    |> Enum.with_index()
    |> Enum.map(fn
      {skill_category_item, 0} -> [skill_unit_item] ++ skill_category_item
      {skill_category_item, _i} -> [nil] ++ skill_category_item
    end)
  end
end
