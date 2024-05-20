defmodule Bright.UserSearches do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false

  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillScores.SkillClassScore
  alias Bright.UserJobProfiles.UserJobProfile

  @doc """
  search user by user_job_profile and skill_class_score

  job_params(Keyword List) ->
    job_searching, wish_employed, wish_change_job, wish_side_job, wish_freelance,
    office_work, office_pref, office_working_hours, office_work_holidays,
    remote_work, remote_working_hours, remote_work_holidays

  job_range_params(Map) ->
    desired_income -> desired_income

  skills(List) ->
    skill_panel, class, level

  ## Examples

    iex> search_users_by_job_profile_and_skill_score(
      {
        [
          {job_searching: true},
          {wish_side_job: true},
          {remote_work: true}
        ],
        %{desired_income: 1000},
        [
          %{skill_panel: "skill_panel_1_id", class: 1, level: :normal},
          %{skill_panel: "skill_panel_2_id"}
        ]
      },
      exclude_user_id: ["exlucede_user_id"],
      page: 1,
      sort: :last_update_desc
    )
    [%User{}]

  """
  def search_users_by_job_profile_and_skill_score(
        {job_params, job_range_params, skill_params},
        options \\ []
      ) do
    default = [exclude_user_ids: [], page: 1, sort: :last_updated_desc]

    %{exclude_user_ids: exclude_user_ids, page: page, sort: sort} =
      Keyword.merge(default, options)
      |> Enum.into(%{})

    # user_job_profileとskill_paramsのskill_panel_idで絞り込んだ skill_scoreの一覧
    skill_scores =
      skill_score_query(exclude_user_ids, job_params, job_range_params)
      |> skill_query(skill_params)
      |> Repo.all()

    # skill_scoreをskill_paramsのskill_panel_id,class,levelでフィルタリングして
    # skill_paramsのすべての条件を満たすユーザーのIDのみを抽出
    user_ids = filter_skill_class_and_level(skill_scores, skill_params)

    # ソート用の1つ目のskill_paramsのskill_classのidを取得
    skill_class_id =
      get_first_skill_query_params_skill_class_id(skill_scores, List.first(skill_params))

    from(
      u in User,
      where: u.id in ^user_ids,
      left_join: s_score in assoc(u, :skill_scores),
      join: job in assoc(u, :user_job_profile),
      left_join: sc_score in assoc(u, :skill_class_scores),
      on: sc_score.skill_class_id in ^skill_class_id,
      group_by: [u.id, job.id],
      preload: [:skill_class_scores, :user_job_profile, :user_profile],
      # 匿名リンク生成のためUserを保ったまま、ソート用カラムを追加している
      select: %{
        u
        | last_updated: fragment("MAX(?) AS last_updated", s_score.updated_at),
          desired_income: fragment("? AS desired_income", job.desired_income),
          skill_score: fragment("MAX(?) AS skill_score", sc_score.percentage)
      }
    )
    |> set_order(sort)
    |> Repo.paginate(page: page, page_size: 5)
  end

  def get_user_by_id_with_job_profile_and_skill_score(
        user_id,
        [%{skill_panel: skill_panel_id} | _]
      ) do
    skill_class_id =
      from(
        sc in SkillClass,
        where: sc.skill_panel_id == ^skill_panel_id and sc.class == 1,
        select: sc.id
      )
      |> Repo.all()

    from(
      u in User,
      where: u.id == ^user_id,
      left_join: s_score in assoc(u, :skill_scores),
      join: job in assoc(u, :user_job_profile),
      left_join: sc_score in assoc(u, :skill_class_scores),
      on: sc_score.skill_class_id in ^skill_class_id,
      group_by: [u.id, job.id],
      preload: [:skill_class_scores, :user_job_profile, :user_profile],
      # 匿名リンク生成のためUserを保ったまま、ソート用カラムを追加している
      select: %{
        u
        | last_updated: fragment("MAX(?) AS last_updated", s_score.updated_at),
          desired_income: fragment("? AS desired_income", job.desired_income),
          skill_score: fragment("MAX(?) AS skill_score", sc_score.percentage)
      }
    )
    |> Repo.all()
  end

  def generate_search_params_from_skill_panel_name(skill_panel_name) do
    skill_panel =
      Bright.SkillPanels.SkillPanel
      |> Repo.get_by(name: skill_panel_name)

    [
      %{
        skill_panel_name: skill_panel_name,
        skill_panel: skill_panel.id
      }
    ]
  end

  # joinしたデータで動的なorderを設定する場合は fragment asでschemaのvirtual fieldのカラム名を指定する
  defp set_order(query, :last_updated_desc),
    do: order_by(query, [{:desc, fragment("last_updated")}])

  defp set_order(query, :last_updated_asc),
    do: order_by(query, [{:asc, fragment("last_updated")}])

  defp set_order(query, :income_desc),
    do:
      order_by(query, [
        {:desc_nulls_last, fragment("desired_income")},
        {:desc, fragment("last_updated")}
      ])

  defp set_order(query, :income_asc),
    do:
      order_by(query, [
        {:asc_nulls_last, fragment("desired_income")},
        {:desc, fragment("last_updated")}
      ])

  defp set_order(query, :score_desc),
    do: order_by(query, [{:desc, fragment("skill_score")}, {:desc, fragment("last_updated")}])

  defp set_order(query, :score_asc),
    do: order_by(query, [{:asc, fragment("skill_score")}, {:desc, fragment("last_updated")}])

  defp get_first_skill_query_params_skill_class_id(_scores, nil), do: []

  defp get_first_skill_query_params_skill_class_id(skill_scores, skill_param) do
    Enum.filter(skill_scores, fn score ->
      score.skill_panel_id == Map.get(skill_param, :skill_panel) &&
        score.skill_class == Map.get(skill_param, :class, 1)
    end)
    |> Enum.map(& &1.skill_class_id)
  end

  # job_profile_queryで絞り込んだユーザーのスキルスコアを取得する
  defp skill_score_query(user_id, job, job_range) do
    from(
      score in SkillClassScore,
      join: sc in assoc(score, :skill_class),
      where: score.user_id in subquery(job_profile_query(user_id, job, job_range)),
      select: %{
        user_id: score.user_id,
        level: score.level,
        skill_panel_id: sc.skill_panel_id,
        skill_class: sc.class,
        skill_class_id: sc.id
      }
    )
  end

  # classとlevelも含めると複雑すぎるので、skill_class_scoreのskill_panel_idでのみ絞り込み
  defp skill_query(query, []), do: query

  defp skill_query(query, skills) do
    where(
      query,
      [score],
      score.skill_class_id in subquery(
        from(
          sc in SkillClass,
          where: sc.skill_panel_id in ^Enum.map(skills, &Map.get(&1, :skill_panel)),
          select: sc.id
        )
      )
    )
  end

  defp job_profile_query(exclude_user_ids, job, job_range) do
    base_query =
      Keyword.take(job, [
        :job_searching,
        :wish_employed,
        :wish_change_job,
        :wish_side_job,
        :wish_freelance,
        :office_work,
        :remote_work
      ])

    from(
      job in UserJobProfile,
      where: ^base_query,
      select: job.user_id
    )
    |> where([j], j.user_id not in ^exclude_user_ids)
    |> then(
      &if job[:office_work],
        do:
          &1
          |> office_pref_query(job[:office_pref])
          |> office_working_hours_query(job[:office_working_hours])
          |> office_work_holidays_query(job[:office_work_holidays]),
        else: &1
    )
    |> then(
      &if job[:remote_work],
        do:
          &1
          |> remote_working_hours_query(job[:remote_working_hours])
          |> remote_work_holidays_query(job[:remote_work_holidays]),
        else: &1
    )
    |> desired_income_query(job_range)
  end

  defp office_pref_query(query, nil), do: query

  defp office_pref_query(query, pref),
    do: where(query, [j], j.office_pref == ^pref or is_nil(j.office_pref))

  defp office_working_hours_query(query, nil), do: query

  defp office_working_hours_query(query, hours),
    do: where(query, [j], j.office_working_hours == ^hours or is_nil(j.office_working_hours))

  defp office_work_holidays_query(query, nil), do: query

  defp office_work_holidays_query(query, holidays),
    do: where(query, [j], j.office_work_holidays == ^holidays)

  defp remote_working_hours_query(query, nil), do: query

  defp remote_working_hours_query(query, hours),
    do: where(query, [j], j.remote_working_hours == ^hours or is_nil(j.remote_working_hours))

  defp remote_work_holidays_query(query, nil), do: query

  defp remote_work_holidays_query(query, holidays),
    do: where(query, [j], j.remote_work_holidays == ^holidays)

  # job_profile 希望年収
  defp desired_income_query(query, %{desired_income: income}) do
    where(query, [j], j.desired_income <= ^income or is_nil(j.desired_income))
  end

  defp desired_income_query(query, _range_params), do: query

  # スキルのclassとlevelでの絞り込み
  defp filter_skill_class_and_level(skill_scores, []), do: Enum.map(skill_scores, & &1.user_id)

  defp filter_skill_class_and_level(skill_scores, skills) do
    # 検索条件skills毎にフィルタリングしたユーザーIDのユニークなリストを作成
    Enum.map(skills, fn params ->
      filter(skill_scores, :skill_panel_id, Map.get(params, :skill_panel))
      |> filter(:skill_class, class_nil_check(Map.get(params, :class)))
      |> filter(:level, level_to_atom(Map.get(params, :level)))
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()
    end)
    # 結合して同一のユーザーIDでグルーピングし、検索条件の数と一致するユーザーIDのみフィルタリング
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, val} -> val == Enum.count(skills) end)
    |> Enum.map(fn {key, _val} -> key end)
  end

  defp class_nil_check(class) when is_nil(class), do: 1
  defp class_nil_check(class), do: class
  defp level_to_atom(level) when level in ["", nil], do: nil
  defp level_to_atom(level), do: String.to_atom(level)

  defp filter(list, _key, nil), do: list

  defp filter(list, key, value) do
    Enum.filter(list, &(Map.get(&1, key) == value))
  end
end
