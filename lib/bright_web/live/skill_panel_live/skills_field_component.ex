defmodule BrightWeb.SkillPanelLive.SkillsFieldComponent do
  # スキルパネル画面 スキル一覧を表示するコンポーネント
  # タイムライン操作に基づいて適当なスキル一覧の表示を行う
  #
  # （スキルスコア入力に関しては、LiveViewで行いこちらでは制御しない）

  use BrightWeb, :live_component

  import BrightWeb.SkillPanelLive.SkillsComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper, only: [calc_percentage: 2]

  alias Bright.SkillUnits
  alias Bright.SkillScores

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.compares current_user={@current_user} myself={@myself} />
      <.skills_table
         table_structure={@table_structure}
         skill_panel={@skill_panel}
         skill_score_dict={@skill_score_dict}
         focus_row={@focus_row}
         counter={@counter}
         num_skills={@num_skills}
         compared_users={@compared_users}
         compared_users_stats={@compared_users_stats}
         compared_user_dict={@compared_user_dict}
         path={@path}
         query={@query}
         focus_user={@focus_user}
         editable={@editable}
         edit={@edit}
         myself={@myself}
      />
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(compared_users: [], compared_user_dict: %{})}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_skill_units()
     |> assign_table_structure()
     # 初期は「現在」
     |> assign(:skill_score_dict, assigns.current_skill_score_dict)
     |> assign_compared_users_info()}
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
       |> assign_compared_user_dict(user)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reject_compared_user", %{"name" => name}, socket) do
    {:noreply,
     socket
     |> update(:compared_users, fn users -> Enum.reject(users, &(&1.name == name)) end)
     |> update(:compared_user_dict, &Map.delete(&1, name))}
  end

  def handle_event("timeline_bar_button_click", _params, socket) do
    {:noreply, socket}
  end

  def assign_skill_units(socket) do
    skill_units =
      Ecto.assoc(socket.assigns.skill_class, :skill_units)
      |> SkillUnits.list_skill_units()
      |> Bright.Repo.preload(skill_categories: [skills: [:skill_reference, :skill_exam]])

    skills =
      skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    socket
    |> assign(skill_units: skill_units)
    |> assign(skills: skills)
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
