defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias BrightWeb.SkillPanelLive.SkillScoreItemComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:edit, false)}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    skill_score_author?(socket.assigns.skill_score, socket.assigns.current_user)
    |> if do
      {:noreply, socket |> assign(edit: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update", _params, socket) do
    target_skill_score_items =
      socket.assigns.skill_score_item_dict
      |> Map.values()
      |> Enum.filter(& &1.changed)

    {:ok, %{skill_score: skill_score}} =
      SkillScores.update_skill_score_items(socket.assigns.skill_score, target_skill_score_items)

    {:noreply,
     socket
     |> assign(skill_score: skill_score)
     |> assign_skill_score_item_dict()
     |> assign_counter()
     |> assign(edit: false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_score_if_not_existing()
     |> assign_skill_units()
     |> assign_skill_score_item_dict()
     |> assign_counter()
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

  @impl true
  def handle_info({SkillScoreItemComponent, {:score_change, skill_score_item, score}}, socket) do
    # 習得率の変動反映
    current_score = skill_score_item.score

    counter =
      socket.assigns.counter
      |> Map.update!(current_score, &(&1 - 1))
      |> Map.update!(score, &(&1 + 1))

    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_item_dict =
      socket.assigns.skill_score_item_dict
      |> Map.put(skill_score_item.skill_id, %{skill_score_item | score: score, changed: true})

    {:noreply,
     socket
     |> assign(
       counter: counter,
       skill_score_item_dict: skill_score_item_dict
     )}
  end

  defp assign_skill_panel(socket, skill_panel_id) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(skill_panel_id)
      |> Bright.Repo.preload(
        skill_classes: [skill_scores: Ecto.assoc(current_user, :skill_scores)]
      )

    socket
    |> assign(:skill_panel, skill_panel)
  end

  defp assign_skill_class_and_score(socket, nil), do: assign_skill_class_and_score(socket, "1")

  defp assign_skill_class_and_score(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_score = skill_class.skill_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_score, skill_score)
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

  defp create_skill_score_if_not_existing(%{assigns: %{skill_score: nil}} = socket) do
    # NOTE: skill_scoreが存在しないときの生成処理について
    # 管理側でスキルクラスを増やすなどの操作も想定し、
    # アクセスしたタイミングで生成するようにしています。
    {:ok, %{skill_score: skill_score}} =
      SkillScores.create_skill_score(
        socket.assigns.current_user,
        socket.assigns.skill_class
      )

    socket
    |> assign(skill_score: skill_score)
  end

  defp create_skill_score_if_not_existing(socket), do: socket

  defp assign_skill_score_item_dict(socket) do
    skill_score_item_dict =
      Ecto.assoc(socket.assigns.skill_score, :skill_score_items)
      |> SkillScores.list_skill_score_items()
      |> Map.new(&{&1.skill_id, Map.put(&1, :changed, false)})

    socket
    |> assign(skill_score_item_dict: skill_score_item_dict)
  end

  defp assign_counter(socket) do
    counter =
      socket.assigns.skill_score_item_dict
      |> Map.values()
      |> Enum.reduce(%{low: 0, middle: 0, high: 0}, fn skill_score_item, acc ->
        Map.update!(acc, skill_score_item.score, &(&1 + 1))
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

  defp skill_score_author?(skill_score, user) do
    skill_score.user_id == user.id
  end

  defp skill_reference_existing?(skill_reference) do
    skill_reference && skill_reference.url
  end

  defp skill_exam_existing?(skill_exam) do
    skill_exam && skill_exam.url
  end
end
