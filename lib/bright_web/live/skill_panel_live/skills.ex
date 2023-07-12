defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores

  @impl true
  def mount(params, _session, socket) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(params["skill_panel_id"])
      |> Bright.Repo.preload(
        skill_classes: [skill_scores: Ecto.assoc(current_user, :skill_scores)]
      )

    {:ok,
     socket
     |> assign(:skill_panel, skill_panel)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skill_class(params["class"])
     |> assign_skill_units()
     |> assign_skill_score()
     |> assign_skill_score_item_dict()
     |> assign_counter()}
  end

  defp assign_skill_class(socket, nil), do: assign_skill_class(socket, "1")

  defp assign_skill_class(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))

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

  defp assign_skill_score(socket) do
    # NOTE: skill_scoreが存在しないときの生成処理について
    # 管理側でスキルクラスを増やすなどの操作も想定し、
    # アクセスしたタイミングでもって生成するようにしています。
    skill_score =
      socket.assigns.skill_class.skill_scores
      # List.first(): preload時に絞り込んでいるためfirstで取得可能
      |> List.first()
      |> case do
        nil ->
          SkillScores.create_skill_score(%{
            user_id: socket.assigns.current_user.id,
            skill_class_id: socket.assigns.skill_class.id
          })
          |> elem(1)

        skill_score ->
          skill_score
      end

    socket
    |> assign(skill_score: skill_score)
  end

  defp assign_skill_score_item_dict(socket) do
    skill_score_item_dict =
      Ecto.assoc(socket.assigns.skill_score, :skill_score_items)
      |> SkillScores.list_skill_score_items()
      |> Map.new(&{&1.skill_id, &1})

    socket
    |> assign(skill_score_item_dict: skill_score_item_dict)
  end

  defp assign_counter(socket) do
    counter =
      socket.assigns.skill_score_item_dict
      |> Map.values()
      |> Enum.reduce(%{low: 0, middle: 0, high: 0}, fn skill_score_item, acc ->
        Map.update!(acc, skill_score_item.score, & &1 + 1)
      end)

    num_skills =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.map(&Enum.count(&1.skills))
      |> Enum.sum()

    socket
    |> assign(counter: counter, num_skills: num_skills)
  end

  defp calc_percentage(count, num_skills) do
    (count  / num_skills)
    |> Kernel.*(100)
    |> floor()
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
