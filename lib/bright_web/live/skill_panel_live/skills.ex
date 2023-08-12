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
     |> assign(:compaired_users, ["mokichi", "koyo"])
     |> assign_compaired_users_info()
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

  def handle_event("clear_focus_user", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(to: ~p"/panels/#{socket.assigns.skill_panel}/skills")}
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

  defp assign_compaired_users_info(socket) do
    # 比較対象になっているユーザーのデータを表示用に整理・集計
    stats = %{
      # スキルから数を引く
    }
    dict = %{
      "mokichi" => %{
        #スキルからスコアを引く
        skill_score_dict: %{},
        high_percentage: 0,
        low_percentage: 0,
      },
      "koyo" => %{
        skill_score_dict: %{},
        high_percentage: 0,
        low_percentage: 0,
      }
    }

    socket
    |> assign(:compaired_users_dict, dict)
    |> assign(:compaired_users_stats, stats)
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
