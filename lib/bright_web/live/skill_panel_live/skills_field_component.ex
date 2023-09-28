defmodule BrightWeb.SkillPanelLive.SkillsFieldComponent do
  # スキルパネル画面 スキル一覧を表示するコンポーネント
  # タイムライン操作に基づいて適当なスキル一覧の表示を行う
  #
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper, only: [calc_percentage: 2, assign_counter: 1]

  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.HistoricalSkillUnits
  alias Bright.HistoricalSkillPanels
  alias Bright.HistoricalSkillScores
  alias BrightWeb.SkillPanelLive.TimelineHelper
  alias BrightWeb.BrightCoreComponents
  alias BrightWeb.DisplayUserHelper

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <BrightCoreComponents.flash_group flash={@inner_flash} />
      <.compares current_user={@current_user} myself={@myself} timeline={@timeline} />
      <div class="hidden lg:block">
        <.skills_table
          table_structure={@table_structure}
          skill_panel={@skill_panel}
          skill_score_dict={@skill_score_dict}
          counter={@counter}
          num_skills={@num_skills}
          compared_users={@compared_users}
          compared_users_stats={@compared_users_stats}
          compared_user_dict={@compared_user_dict}
          path={@path}
          query={@query}
          display_user={@display_user}
          current_skill_dict={@current_skill_dict}
          current_skill_score_dict={@current_skill_score_dict}
          myself={@myself}
          me={@me}
          anonymous={@anonymous}
        />
      </div>
      <div class="lg:hidden" :if={Mix.env() != :test}>
        <.skills_table_sp
          skill_panel={@skill_panel}
          skill_score_dict={@skill_score_dict}
          skill_class={@skill_class}
          skill_units={@skill_units}
          skill_class_score={@skill_class_score}
          query={@query}
          current_skill_dict={@current_skill_dict}
          current_skill_score_dict={@current_skill_score_dict}
          myself={@myself}
          me={@me}
        />
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(skill_class: nil)
     |> assign(compared_users: [], compared_user_dict: %{})
     |> assign(timeline: TimelineHelper.get_current())
     |> assign(inner_flash: %{})}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_assigns_with_current_if_updated(assigns)
     |> assign_on_timeline(TimelineHelper.get_selected_tense(socket.assigns.timeline))
     |> assign_compared_users_info()}
  end

  def handle_event("click_on_related_user_card_compare", params, socket) do
    # TODO: 本当に参照可能かのチェックをいれること
    {user, anonymous} =
      DisplayUserHelper.get_user_from_name_or_name_encrypted(
        params["name"],
        params["encrypt_user_name"]
      )

    user = Map.put(user, :anonymous, anonymous)

    display_user_id = socket.assigns.display_user.id
    existing_user_ids = socket.assigns.compared_users |> Enum.map(& &1.id)

    (user.id == display_user_id or user.id in existing_user_ids)
    |> case do
      false ->
        {:noreply,
         socket
         |> update(:compared_users, &(&1 ++ [user]))
         |> assign_compared_user_dict(user)
         |> assign_compared_users_info()}

      true ->
        {:noreply, assign(socket, :inner_flash, %{error: "既に一覧に表示されています"})}
    end
  end

  def handle_event("reject_compared_user", %{"name" => name}, socket) do
    {:noreply,
     socket
     |> update(:compared_users, fn users -> Enum.reject(users, &(&1.name == name)) end)
     |> update(:compared_user_dict, &Map.delete(&1, name))
     |> assign_compared_users_info()}
  end

  def handle_event("timeline_bar_button_click", %{"date" => date}, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.select_label(date)

    {:noreply,
     socket
     |> clear_for_timeline_changed()
     |> assign(timeline: timeline)
     |> assign_on_timeline(TimelineHelper.get_selected_tense(timeline))}
  end

  def handle_event("shift_timeline_past", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_past()

    {:noreply, socket |> assign(timeline: timeline)}
  end

  def handle_event("shift_timeline_future", _params, socket) do
    timeline =
      socket.assigns.timeline
      |> TimelineHelper.shift_for_future()

    {:noreply, socket |> assign(timeline: timeline)}
  end

  defp assign_assigns_with_current_if_updated(socket, assigns) do
    # 基本的には assigns をアサインするのみ
    # ただし、表示上「現在」の情報を必要とするため、スキルクラスが更新されている場合には「現在」の情報を更新する
    prev_skill_class = socket.assigns.skill_class
    new_skill_class = assigns.skill_class

    if prev_skill_class == new_skill_class do
      socket
      |> assign(assigns)
    else
      socket
      |> assign(assigns)
      |> assign_current_skill_units()
      |> assign_current_skill_dict()
    end
  end

  defp assign_current_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(
        skill_units: [skill_categories: [skills: [:skill_reference, :skill_exam]]]
      )
      |> Map.get(:skill_units)

    skills =
      skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    socket
    |> assign(current_skill_units: skill_units)
    |> assign(current_skills: skills)
  end

  defp assign_current_skill_dict(socket) do
    current_skill_dict =
      socket.assigns.current_skills
      |> Map.new(&{&1.trace_id, &1})

    socket
    |> assign(current_skill_dict: current_skill_dict)
  end

  defp assign_skill_units(socket, :past, label) do
    display_user = socket.assigns.display_user

    historical_skill_class =
      HistoricalSkillPanels.get_historical_skill_class_on_date(
        skill_panel_id: socket.assigns.skill_panel.id,
        class: socket.assigns.skill_class.class,
        date: TimelineHelper.label_to_date(label)
      )
      |> Bright.Repo.preload(
        historical_skill_class_scores: Ecto.assoc(display_user, :historical_skill_class_scores)
      )

    # 過去分のため存在しない可能性がある
    if historical_skill_class do
      skill_units =
        historical_skill_class
        |> Bright.Repo.preload(
          historical_skill_units: [historical_skill_categories: [:historical_skills]]
        )
        |> Map.get(:historical_skill_units)

      skills =
        skill_units
        |> Enum.flat_map(& &1.historical_skill_categories)
        |> Enum.flat_map(& &1.historical_skills)

      socket
      |> assign(skill_units: skill_units)
      |> assign(skills: skills)
      |> assign(historical_skill_class: historical_skill_class)
    else
      socket
      |> assign(skill_units: [])
      |> assign(skills: [])
      |> assign(historical_skill_class: nil)
    end
  end

  defp clear_for_timeline_changed(socket) do
    # スキル一覧で表示するための情報を初期化
    socket
    |> assign(skill_units: [])
    |> assign(skills: [])
    |> assign(skill_score_dict: %{})
    |> assign(table_structure: [])
    |> assign(counter: %{})
    |> assign(num_skills: [])
    |> assign(compared_users_stats: %{})
    |> assign(compared_user_dict: %{})
  end

  defp assign_on_timeline(socket, :now) do
    socket
    |> assign(:tense, :now)
    # 「現在」であればいまの情報で良い
    |> assign(:skill_units, socket.assigns.current_skill_units)
    |> assign(:skills, socket.assigns.current_skills)
    |> assign(:skill_score_dict, socket.assigns.current_skill_score_dict)
    |> assign_table_structure()
    |> assign_counter()
    |> assign_compared_user_dict_from_users()
    |> assign_compared_users_info()
  end

  defp assign_on_timeline(socket, :future) do
    # TODO: スキルアップ機能後に実装
    socket
    |> assign(:tense, :future)
    |> assign_on_timeline(:now)
  end

  defp assign_on_timeline(socket, :past) do
    socket
    |> assign(:tense, :past)
    |> assign_skill_units(:past, socket.assigns.timeline.selected_label)
    |> assign_table_structure()
    |> assign_skill_score_dict(:past)
    |> assign_counter()
    |> assign_compared_user_dict_from_users()
    |> assign_compared_users_info()
  end

  defp assign_skill_score_dict(%{assigns: %{historical_skill_class: nil}} = socket, _past) do
    socket
    |> assign(skill_class_score: nil)
    |> assign(skill_score_dict: %{})
  end

  defp assign_skill_score_dict(socket, :past) do
    skill_class_score =
      socket.assigns.historical_skill_class.historical_skill_class_scores |> List.first()

    skill_score_dict =
      skill_class_score
      |> HistoricalSkillScores.list_historical_skill_scores_from_historical_skill_class_score()
      |> Map.new(&{&1.historical_skill_id, &1})

    socket
    |> assign(skill_class_score: skill_class_score)
    |> assign(skill_score_dict: skill_score_dict)
  end

  defp assign_compared_user_dict_from_users(socket) do
    socket.assigns.compared_users
    |> Enum.reduce(socket, fn user, acc ->
      acc
      |> assign_compared_user_dict(user)
    end)
  end

  defp assign_compared_user_dict(socket, user) do
    # 比較対象になっているユーザーのデータを表示用に整理・集計してアサイン
    skill_ids = Enum.map(socket.assigns.skills, & &1.id)
    skill_scores = list_user_skill_scores_from_skill_ids(skill_ids, user.id, socket.assigns.tense)

    {skill_score_dict, high_skills_count, middle_skills_count} =
      skill_scores
      |> Enum.reduce({%{}, 0, 0}, fn skill_score, {dict, high_c, middle_c} ->
        score = skill_score.score

        {
          dict |> Map.put(skill_scores_skill_id(skill_score), score),
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

  defp assign_table_structure(socket) do
    table_structure = build_table_structure(socket.assigns.skill_units)
    max_row = Enum.count(table_structure)

    socket
    |> assign(:table_structure, table_structure)
    |> assign(:max_row, max_row)
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
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {skill_unit, position} ->
      skill_category_items =
        list_skill_categories(skill_unit)
        |> Enum.flat_map(&build_skill_category_table_structure/1)

      build_skill_unit_table_structure(skill_unit, skill_category_items, position)
    end)
  end

  defp build_skill_category_table_structure(skill_category) do
    skills = list_skills(skill_category)
    size = length(skills)
    skill_category_item = %{size: size, skill_category: skill_category}

    skills
    |> Enum.with_index()
    |> Enum.map(fn
      {skill, 0} -> [skill_category_item] ++ [%{skill: skill}]
      {skill, _i} -> [nil] ++ [%{skill: skill}]
    end)
  end

  defp build_skill_unit_table_structure(skill_unit, skill_category_items, position) do
    size =
      skill_category_items
      |> Enum.reduce(0, fn
        [nil, _], acc -> acc
        [%{size: size}, _], acc -> acc + size
      end)

    skill_unit_item = %{size: size, skill_unit: skill_unit, position: position}

    skill_category_items
    |> Enum.with_index()
    |> Enum.map(fn
      {skill_category_item, 0} -> [skill_unit_item] ++ skill_category_item
      {skill_category_item, _i} -> [nil] ++ skill_category_item
    end)
  end

  defp list_skill_categories(%SkillUnits.SkillUnit{} = skill_unit) do
    skill_unit.skill_categories
  end

  defp list_skill_categories(%HistoricalSkillUnits.HistoricalSkillUnit{} = skill_unit) do
    skill_unit.historical_skill_categories
  end

  defp list_skills(%SkillUnits.SkillCategory{} = skill_category) do
    skill_category.skills
  end

  defp list_skills(%HistoricalSkillUnits.HistoricalSkillCategory{} = skill_category) do
    skill_category.historical_skills
  end

  defp list_user_skill_scores_from_skill_ids(skill_ids, user_id, :now) do
    SkillScores.list_user_skill_scores_from_skill_ids(skill_ids, user_id)
  end

  defp list_user_skill_scores_from_skill_ids(skill_ids, user_id, :future) do
    # TODO: スキルアップ対応後に実装。比較ユーザー分のスキルアップを加味する（大変そう）
    SkillScores.list_user_skill_scores_from_skill_ids(skill_ids, user_id)
  end

  defp list_user_skill_scores_from_skill_ids(skill_ids, user_id, :past) do
    HistoricalSkillScores.list_user_historical_skill_scores_from_historical_skill_ids(
      skill_ids,
      user_id
    )
  end

  defp skill_scores_skill_id(%SkillScores.SkillScore{} = skill_score) do
    skill_score.skill_id
  end

  defp skill_scores_skill_id(
         %HistoricalSkillScores.HistoricalSkillScore{} = historical_skill_score
       ) do
    historical_skill_score.historical_skill_id
  end
end
