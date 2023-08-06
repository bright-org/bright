defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillsComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents

  alias BrightWeb.BrightCoreComponents
  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign_edit_off()
      |> assign(:page_flash, %{})}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    skill_class_score_author?(socket.assigns.skill_class_score, socket.assigns.current_user)
    |> if do
      {:noreply, socket |> assign_edit_on()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("submit", _params, socket) do
    target_skill_scores =
      socket.assigns.skill_score_dict
      |> Map.values()
      |> Enum.filter(& &1.changed)

    {:ok, %{skill_class_score: skill_class_score}} =
      SkillScores.update_skill_scores(socket.assigns.skill_class_score, target_skill_scores)

    {:noreply,
     socket
     |> assign(skill_class_score: skill_class_score)
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_edit_off()
     |> assign(:page_flash, %{info: "Skill scores updated successfully"})}
  end

  def handle_event("change", %{"score" => score, "row" => row}, socket) do
    score = String.to_atom(score)
    row = String.to_integer(row)
    skill_score = get_skill_score_from_table_structure(socket, row)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> assign(focus_row: row)}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    row = socket.assigns.focus_row
    skill_score = get_skill_score_from_table_structure(socket, row)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.max_row]))}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.max_row]))}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.max([1, &1 - 1]))}
  end

  def handle_event("shortcut", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_units()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_table_structure()
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params), do: socket

  defp apply_action(socket, :show_evidences, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_evidence()
    |> create_skill_evidence_if_not_existing()
  end

  defp apply_action(socket, :show_reference, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_reference()
  end

  defp apply_action(socket, :show_exam, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_exam()
  end

  defp assign_skill_panel(socket, skill_panel_id) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(skill_panel_id)
      |> Bright.Repo.preload(
        skill_classes: [skill_class_scores: Ecto.assoc(current_user, :skill_class_scores)]
      )

    socket
    |> assign(:skill_panel, skill_panel)
  end

  defp assign_skill_class_and_score(socket, nil), do: assign_skill_class_and_score(socket, "1")

  defp assign_skill_class_and_score(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  defp assign_skill_units(socket) do
    # query chainを作るか専用の関数を作るか悩んだため、後で見直し
    import Ecto.Query, only: [preload: 2]

    skill_units =
      Ecto.assoc(socket.assigns.skill_class, :skill_units)
      |> preload(skill_categories: [skills: [:skill_reference, :skill_exam]])
      |> SkillUnits.list_skill_units()

    socket
    |> assign(skill_units: skill_units)
  end

  defp create_skill_class_score_if_not_existing(%{assigns: %{skill_class_score: nil}} = socket) do
    # NOTE: skill_class_scoreが存在しないときの生成処理について
    # 管理側でスキルクラスを増やすなどの操作も想定し、
    # アクセスしたタイミングで生成するようにしています。
    {:ok, %{skill_class_score: skill_class_score}} =
      SkillScores.create_skill_class_score(
        socket.assigns.current_user,
        socket.assigns.skill_class
      )

    socket
    |> assign(skill_class_score: skill_class_score)
  end

  defp create_skill_class_score_if_not_existing(socket), do: socket

  defp assign_skill_score_dict(socket) do
    skill_score_dict =
      Ecto.assoc(socket.assigns.skill_class_score, :skill_scores)
      |> SkillScores.list_skill_scores()
      |> Map.new(&{&1.skill_id, Map.put(&1, :changed, false)})

    socket
    |> assign(skill_score_dict: skill_score_dict)
  end

  defp assign_counter(socket) do
    counter =
      socket.assigns.skill_score_dict
      |> Map.values()
      |> Enum.reduce(%{low: 0, middle: 0, high: 0}, fn skill_score, acc ->
        Map.update!(acc, skill_score.score, &(&1 + 1))
      end)

    num_skills =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.map(&Enum.count(&1.skills))
      |> Enum.sum()

    socket
    |> assign(counter: counter, num_skills: num_skills)
  end

  defp assign_skill(socket, skill_id) do
    skill =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)
      |> Enum.find(&(&1.id == skill_id))

    socket |> assign(skill: skill)
  end

  defp assign_edit_off(socket) do
    socket
    |> assign(edit: false, focus_row: nil)
  end

  defp assign_edit_on(socket) do
    socket
    |> assign(edit: true, focus_row: 1)
  end

  defp assign_table_structure(socket) do
    table_structure = build_table_structure(socket.assigns.skill_units)
    max_row = Enum.count(table_structure)

    socket
    |> assign(:table_structure, table_structure)
    |> assign(:max_row, max_row)
  end

  defp assign_skill_evidence(socket) do
    skill_evidence =
      SkillEvidences.get_skill_evidence_by(
        user_id: socket.assigns.current_user.id,
        skill_id: socket.assigns.skill.id
      )

    socket
    |> assign(skill_evidence: skill_evidence)
  end

  defp assign_skill_reference(socket) do
    skill_reference = SkillReferences.get_skill_reference_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_reference: skill_reference)
  end

  defp assign_skill_exam(socket) do
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_exam: skill_exam)
  end

  defp update_by_score_change(socket, skill_score, score) do
    # 習得率の変動反映
    current_score = skill_score.score

    counter =
      socket.assigns.counter
      |> Map.update!(current_score, &(&1 - 1))
      |> Map.update!(score, &(&1 + 1))

    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    socket
    |> assign(
      counter: counter,
      skill_score_dict: skill_score_dict
    )
  end

  defp create_skill_evidence_if_not_existing(%{assigns: %{skill_evidence: nil}} = socket) do
    {:ok, skill_evidence} =
      SkillEvidences.create_skill_evidence(%{
        user_id: socket.assigns.current_user.id,
        skill_id: socket.assigns.skill.id,
        progress: :wip,
        skill_evidence_posts: []
      })

    socket
    |> assign(skill_evidence: skill_evidence)
  end

  defp create_skill_evidence_if_not_existing(socket), do: socket

  defp calc_percentage(_count, 0), do: 0

  defp calc_percentage(count, num_skills) do
    (count / num_skills)
    |> Kernel.*(100)
  end

  defp get_skill_score_from_table_structure(socket, row) do
    skill =
      socket.assigns.table_structure
      |> Enum.at(row - 1)
      # col3
      |> Enum.at(2)
      |> Map.get(:skill)

    socket.assigns.skill_score_dict[skill.id]
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

  defp skill_class_score_author?(skill_class_score, user) do
    skill_class_score.user_id == user.id
  end

  defp skill_reference_existing?(skill_reference) do
    skill_reference && skill_reference.url
  end

  defp skill_exam_existing?(skill_exam) do
    skill_exam && skill_exam.url
  end

  defp score_mark_class(skill_score) do
    skill_score.score
    |> case do
      :high ->
        "score-mark-high h-4 w-4 rounded-full bg-brightGreen-600"

      :middle ->
        "score-mark-middle h-0 w-0 border-solid border-t-0 border-r-8 border-l-8 border-transparent border-b-[14px] border-b-brightGreen-300"

      :low ->
        "score-mark-low h-1 w-4 bg-brightGray-200"
    end
  end
end
