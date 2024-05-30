defmodule BrightWeb.SkillPanelLive.SkillsFieldComponent do
  # スキルパネル画面 スキル一覧を表示するコンポーネント
  # タイムライン操作に基づいて適当なスキル一覧の表示を行う
  #
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents

  import BrightWeb.SkillPanelLive.SkillPanelHelper,
    only: [assign_counter: 1, comparable_user?: 2]

  alias Bright.SkillScores
  alias Bright.HistoricalSkillPanels
  alias Bright.HistoricalSkillScores
  alias Bright.Teams
  alias Bright.CustomGroups
  alias Bright.Utils.SkillsTableStructure
  alias BrightWeb.TimelineHelper
  alias BrightWeb.BrightCoreComponents
  alias BrightWeb.DisplayUserHelper

  def render(assigns) do
    ~H"""
    <div id={@id} class="mt-0 lg:mt-4">
      <BrightCoreComponents.flash_group flash={@inner_flash} />
      <div class="hidden lg:block px-6">
        <.compare_buttons
          current_user={@current_user}
          myself={@myself}
          custom_group={@custom_group}
          compared_users={@compared_users}
          skills_field_id={@id}
        />
      </div>

      <div class="flex px-6 items-center">
        <div class="hidden lg:flex">
          <.compare_timeline myself={@myself} timeline={@timeline} />
        </div>
      </div>

      <div class="px-6 mt-4 lg:mt-8 hidden lg:block">
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
      <div class="lg:hidden px-2">
        <.skills_table_sp
          skill_panel={@skill_panel}
          skill_score_dict={@skill_score_dict}
          skill_class={@skill_class}
          skill_units={@skill_units}
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
     |> assign(custom_group: nil)
     |> clear_inner_flash()}
  end

  def update(%{custom_group_created: custom_group}, socket) do
    {:ok, assign(socket, :custom_group, custom_group)}
  end

  def update(%{custom_group_selected: custom_group}, socket) do
    # カスタムグループ選択時
    %{current_user: current_user, display_user: display_user} = socket.assigns

    users =
      CustomGroups.list_and_filter_valid_users(custom_group, current_user)
      |> Enum.map(&Map.put(&1, :anonymous, false))
      |> Enum.reject(&(&1.id == display_user.id))

    {:ok,
     socket
     |> assign(:custom_group, custom_group)
     |> assign(compared_users: users, compared_user_dict: %{})
     |> assign_compared_users_dict(users)
     |> assign_compared_users_info()}
  end

  def update(%{custom_group_assigned: custom_group}, socket) do
    {:ok, assign(socket, :custom_group, custom_group)}
  end

  def update(%{custom_group_updated: custom_group}, socket) do
    {:ok, assign(socket, :custom_group, custom_group)}
  end

  def update(%{custom_group_deleted: _custom_group}, socket) do
    {:ok, assign(socket, :custom_group, nil)}
  end

  def update(assigns, socket) do
    timeline = get_init_timeline(assigns.init_timeline)

    {:ok,
     socket
     |> assign_assigns_with_current_if_updated(assigns)
     |> assign(:timeline, timeline)
     |> assign_on_timeline(TimelineHelper.get_selected_tense(timeline))
     |> assign_compared_users_from_team(assigns.init_team_id)
     |> assign_compared_users_info()}
  end

  def handle_event("click_on_related_user_card_compare", params, socket) do
    {user, anonymous} =
      DisplayUserHelper.get_user_from_name_or_name_encrypted(
        params["name"],
        params["encrypt_user_name"]
      )

    user = Map.put(user, :anonymous, anonymous)

    display_user_id = socket.assigns.display_user.id
    existing_user_ids = Enum.map(socket.assigns.compared_users, & &1.id)

    user.id == display_user_id or user.id in existing_user_ids

    comparable_user?(user, socket.assigns)
    |> if do
      {:noreply,
       socket
       |> update(:compared_users, &(&1 ++ [user]))
       |> assign_compared_user_dict(user)
       |> assign_compared_users_info()
       |> clear_inner_flash()}
    else
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

  # 「個人とスキルを比較」チーム選択時のイベント
  def handle_event("on_card_row_click", %{"team_id" => team_id}, socket) do
    %{
      current_user: current_user,
      display_user: display_user,
      compared_users: compared_users
    } = socket.assigns

    existing_user_ids = Enum.map(compared_users, & &1.id)
    {team, users} = list_users_in_team(team_id, display_user.id, current_user)

    users
    |> Enum.reject(&(&1.id in existing_user_ids))
    |> case do
      [] ->
        (users == [])
        |> if do
          {:noreply, assign(socket, :inner_flash, %{error: "#{team.name} チームメンバーがいません"})}
        else
          {:noreply, assign(socket, :inner_flash, %{error: "#{team.name} 既に一覧にメンバーが表示されています"})}
        end

      users ->
        {:noreply,
         socket
         |> update(:compared_users, &(&1 ++ users))
         |> assign_compared_users_dict(users)
         |> assign_compared_users_info()
         |> clear_inner_flash()}
    end
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

    locked_date =
      TimelineHelper.label_to_date(label)
      |> TimelineHelper.get_shift_date_from_date(-1)

    historical_skill_class =
      HistoricalSkillPanels.get_historical_skill_class_on_date(
        skill_panel_id: socket.assigns.skill_panel.id,
        class: socket.assigns.skill_class.class,
        locked_date: locked_date
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

    skill_score_dict =
      Map.new(socket.assigns.skills, fn skill ->
        skill_score =
          Map.get(skill_score_dict, skill.id)
          |> Kernel.||(%HistoricalSkillScores.HistoricalSkillScore{
            historical_skill_id: skill.id,
            score: :low
          })

        {skill.id, skill_score}
      end)

    socket
    |> assign(skill_class_score: skill_class_score)
    |> assign(skill_score_dict: skill_score_dict)
  end

  defp assign_compared_user_dict_from_users(socket) do
    assign_compared_users_dict(socket, socket.assigns.compared_users)
  end

  defp assign_compared_users_dict(socket, users) do
    users
    |> Enum.reduce(socket, fn user, acc ->
      assign_compared_user_dict(acc, user)
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
        skill_id = skill_scores_skill_id(skill_score)

        {
          Map.put(dict, skill_id, score),
          high_c + if(score == :high, do: 1, else: 0),
          middle_c + if(score == :middle, do: 1, else: 0)
        }
      end)

    size = Enum.count(skill_ids)
    high_skills_percentage = SkillScores.calc_high_skills_percentage(high_skills_count, size)

    middle_skills_percentage =
      SkillScores.calc_middle_skills_percentage(middle_skills_count, size)

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

  defp list_users_in_team(team_id, display_user_id, current_user) do
    team = Teams.get_team_with_member_users!(team_id)

    member_users =
      team.member_users
      |> Enum.filter(& &1.invitation_confirmed_at)
      |> Teams.sort_team_member_users()

    (current_user.id in Enum.map(member_users, & &1.user_id))
    |> if do
      users =
        member_users
        |> Enum.map(&Map.put(&1.user, :anonymous, false))
        |> Enum.reject(&(&1.id == display_user_id))

      {team, users}
    else
      {team, []}
    end
  end

  defp assign_compared_users_from_team(socket, nil), do: socket

  defp assign_compared_users_from_team(socket, team_id) do
    %{
      current_user: current_user,
      display_user: display_user,
      compared_users: compared_users
    } = socket.assigns

    existing_user_ids = Enum.map(compared_users, & &1.id)

    {_team, users} = list_users_in_team(team_id, display_user.id, current_user)
    users = Enum.reject(users, &(&1.id in existing_user_ids))

    socket
    |> update(:compared_users, &(&1 ++ users))
    |> assign_compared_users_dict(users)
    |> assign_compared_users_info()
  end

  defp assign_table_structure(socket) do
    table_structure = SkillsTableStructure.build(socket.assigns.skill_units)
    max_row = Enum.count(table_structure)

    socket
    |> assign(:table_structure, table_structure)
    |> assign(:max_row, max_row)
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

  defp clear_inner_flash(socket) do
    assign(socket, :inner_flash, %{})
  end

  defp get_init_timeline(nil) do
    TimelineHelper.get_current()
  end

  defp get_init_timeline(init_timeline_label) do
    TimelineHelper.get_by_label(init_timeline_label)
  end
end
