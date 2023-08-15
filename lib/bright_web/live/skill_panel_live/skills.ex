defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillsComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper

  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias Bright.UserSkillPanels

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "スキルパネル")
     |> assign_edit_off()}
  end

  @impl true
  def handle_params(params, url, socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_focus_user(params["user_name"])
     |> assign_skill_panel(params["skill_panel_id"])
     |> assign_skill_classes()
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_units()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_table_structure()
     |> assign_page_sub_title()
     |> assign(compared_users: [], compared_user_dict: %{}, compared_users_stats: %{})
     |> assign_compared_users_info()
     |> apply_action(socket.assigns.live_action, params)}
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

    {:ok, _} = SkillScores.update_skill_scores(socket.assigns.current_user, target_skill_scores)
    skill_class_score = SkillScores.get_skill_class_score!(socket.assigns.skill_class_score.id)

    UserSkillPanels.touch_user_skill_panel_updated(
      socket.assigns.current_user,
      socket.assigns.skill_panel
    )

    {:noreply,
     socket
     |> assign_skill_classes()
     |> assign(skill_class_score: skill_class_score)
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_edit_off()}
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

  # TODO: デモ用実装のため対象ユーザー実装後に削除
  def handle_event("demo_change_user", _params, socket) do
    users =
      Bright.Accounts.User
      |> Bright.Repo.all()
      |> Enum.reject(fn user ->
        user.id == socket.assigns.current_user.id ||
          Ecto.assoc(user, :user_skill_panels)
          |> Bright.Repo.all()
          |> Enum.empty?()
      end)

    if users != [] do
      user = Enum.random(users)

      {:noreply,
       socket
       |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/skills/#{user.name}")}
    else
      {:noreply,
       socket
       |> put_flash(:info, "demo: ユーザーがいません")
       |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/skills")}
    end
  end

  def handle_event("clear_target_user", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/skills")}
  end

  # TODO: デモ用実装のため対象ユーザー実装後に削除
  def handle_event("demo_compare_user", _params, socket) do
    users =
      Bright.Accounts.User
      |> Bright.Repo.all()
      |> Enum.reject(fn user ->
        user.id == socket.assigns.focus_user.id ||
          Ecto.assoc(user, :user_skill_panels)
          |> Bright.Repo.all()
          |> Enum.empty?()
      end)

    if users != [] do
      user = Enum.random(users)

      {:noreply,
       socket
       |> update(:compared_users, &((&1 ++ [user]) |> Enum.uniq()))
       |> assign_compared_user_dict(user)
       |> assign_compared_users_info()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reject_compared_user", %{"name" => name}, socket) do
    {:noreply,
     socket
     |> update(:compared_users, fn users -> Enum.reject(users, &(&1.name == name)) end)
     |> update(:compared_user_dict, &Map.delete(&1, name))
     |> assign_compared_users_info()}
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
    |> update_reference_read()
  end

  defp apply_action(socket, :show_exam, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_exam()
    |> update_exam_progress_wip()
  end

  defp assign_skill(socket, skill_id) do
    skill = socket.assigns.skills |> Enum.find(&(&1.id == skill_id))

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

  defp update_reference_read(socket) do
    skill = socket.assigns.skill
    skill_score = Map.get(socket.assigns.skill_score_dict, skill.id)

    if skill_score.reference_read do
      socket
    else
      {:ok, skill_score} =
        SkillScores.update_skill_score(skill_score, %{"reference_read" => true})

      socket
      |> update(:skill_score_dict, &Map.put(&1, skill.id, skill_score))
    end
  end

  defp assign_skill_exam(socket) do
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_exam: skill_exam)
  end

  defp update_exam_progress_wip(socket) do
    skill = socket.assigns.skill
    skill_score = Map.get(socket.assigns.skill_score_dict, skill.id)

    if skill_score.exam_progress in [:wip, :done] do
      socket
    else
      {:ok, skill_score} = SkillScores.update_skill_score(skill_score, %{"exam_progress" => :wip})

      socket
      |> update(:skill_score_dict, &Map.put(&1, skill.id, skill_score))
    end
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

  defp assign_compared_user_dict(socket, user) do
    # 比較対象になっているユーザーのデータを表示用に整理・集計してアサイン
    skill_ids = Enum.map(socket.assigns.skills, & &1.id)
    skill_scores = SkillScores.list_user_skill_scores_from_skill_ids(user, skill_ids)

    {skill_score_dict, high_skills_count, middle_skills_count} =
      skill_scores
      |> Enum.reduce({%{}, 0, 0}, fn skill_score, {dict, high_c, middle_c} ->
        score = skill_score.score

        {
          dict |> Map.put(skill_score.skill_id, score),
          high_c + if(score == :high, do: 1, else: 0),
          middle_c + if(score == :middle, do: 1, else: 0)
        }
      end)

    size = Enum.count(skill_scores)
    high_skills_percentage = calc_percentage(high_skills_count, size)
    middle_skills_percentage = calc_percentage(middle_skills_count, size)

    socket
    |> update(
      :compared_user_dict,
      &Map.put(&1, user.name, %{
        high_skills_percentage: high_skills_percentage,
        middle_skills_percentage: middle_skills_percentage,
        skill_score_dict: skill_score_dict
      })
    )
  end

  defp assign_compared_users_info(socket) do
    # 比較対象ユーザーのデータを集計してスキルの合計用データをアサイン
    compared_users_stats =
      socket.assigns.skills
      |> Enum.reduce(%{}, fn skill, acc ->
        scores =
          socket.assigns.compared_user_dict
          |> Map.values()
          |> Enum.map(&get_in(&1, [:skill_score_dict, skill.id]))

        acc
        |> Map.put(skill.id, %{
          high_skills_count: Enum.count(scores, &(&1 == :high)),
          middle_skills_count: Enum.count(scores, &(&1 == :middle))
        })
      end)

    socket
    |> assign(compared_users_stats: compared_users_stats)
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
end
