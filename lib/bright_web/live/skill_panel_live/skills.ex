defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias BrightWeb.SkillPanelLive.SkillScoreItemComponent

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

  @impl true
  def handle_info({SkillScoreItemComponent, {:score_change, skill_score_item, score}}, socket) do
    # 習得率の変動反映
    current_score = skill_score_item.score

    counter =
      socket.assigns.counter
      |> Map.update!(current_score, &(&1 - 1))
      |> Map.update!(score, &(&1 + 1))

    # スキルスコア更新
    {:ok, {skill_score, skill_score_item}} =
      Bright.Repo.transaction(fn ->
        percentage = calc_percentage(counter.high, socket.assigns.num_skills)

        {:ok, skill_score_item} =
          SkillScores.update_skill_score_item(skill_score_item, %{score: score})

        {:ok, skill_score} =
          SkillScores.update_skill_score_percentage(socket.assigns.skill_score, percentage)

        {skill_score, skill_score_item}
      end)

    # TODO: streamを一覧に使用するようにリファクタリング検討
    # 親LiveView側に更新が入る関係で skill_score_item_dict の書き換えが必要になったため、現在はそのようにしているが描画効率が良くない
    # ほかの画面更新要素（教材・試験・エビデンス）も実装感をみて対応を決める方針
    skill_score_item_dict =
      socket.assigns.skill_score_item_dict
      |> Map.put(skill_score_item.skill_id, skill_score_item)

    {:noreply,
     socket
     |> assign(
       skill_score: skill_score,
       counter: counter,
       skill_score_item_dict: skill_score_item_dict
     )}
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
      |> preload(skill_categories: [skills: [:skill_reference]])
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
end
