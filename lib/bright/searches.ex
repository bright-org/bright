defmodule Bright.Searches do
  import Ecto.Query, warn: false

  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillScores.SkillClassScore
  alias Bright.UserJobProfiles.UserJobProfile

  def skill_search(user_id, {job, job_range, skills}) do
    job_query =
      from(
        job in UserJobProfile,
        where: ^job,
        select: job.user_id
      )
      |> availability_date_query(job_range)
      |> desired_income_query(job_range)

    user_ids =
      from(
        score in SkillClassScore,
        join: sc in assoc(score, :skill_class),
        where: score.user_id in subquery(job_query),
        select: %{
          user_id: score.user_id,
          level: score.level,
          skill_panel_id: sc.skill_panel_id,
          skill_class: sc.class
        }
      )
      |> skill_query(skills)
      |> Repo.all()
      |> filter_skill_class_and_level(skills)

    from(
      u in User,
      where: u.id in ^user_ids,
      preload: [:skill_class_scores, :user_job_profile]
    )
    |> Repo.all()
  end

  # classとlevelも含めると複雑すぎるので、skill_class_scoreのskill_panel_idでのみ絞り込み
  def skill_query(query, []), do: query

  def skill_query(query, skills) do
    where(
      query,
      [score],
      score.skill_class_id in subquery(
        from(
          sc in SkillClass,
          where: sc.skill_panel_id in ^Enum.map(skills, & &1.skill_panel),
          select: sc.id
        )
      )
    )
  end

  # job_profile 稼働可能日
  def availability_date_query(query, %{pj_start: start_date, pj_end: end_date}) do
    where(
      query,
      [job],
      ^start_date <= job.availability_date and job.availability_date <= ^end_date
    )
  end

  def availability_date_query(query, %{pj_start: start_date}) do
    where(query, [job], ^start_date <= job.availability_date)
  end

  def availability_date_query(query, %{pj_end: end_date}) do
    where(query, [job], job.availability_date <= ^end_date)
  end

  def availability_date_query(query, _range_params), do: query

  def desired_income_query(query, %{desired_income: income}) do
    where(query, [job], job.desired_income <= ^income)
  end

  def desired_income_query(query, _range_params), do: query

  # スキルのclassとlevelでの絞り込み
  def filter_skill_class_and_level(skill_scores, []), do: Enum.map(skill_scores, & &1.user_id)

  def filter_skill_class_and_level(skill_scores, skills) do
    Enum.map(skills, fn params ->
      filter(skill_scores, :skill_panel_id, Map.get(params, :skill_panel))
      |> filter(:skill_class, class_to_integer(Map.get(params, :class)))
      |> filter(:level, level_to_atom(Map.get(params, :level)))
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()
    end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, val} -> val == Enum.count(skills) end)
    |> Enum.map(fn {key, _val} -> key end)
  end

  defp class_to_integer(nil), do: nil
  defp class_to_integer(class), do: String.to_integer(class)
  defp level_to_atom(nil), do: nil
  defp level_to_atom(level), do: String.to_atom(level)

  defp filter(list, _key, nil), do: list

  defp filter(list, key, value) do
    Enum.filter(list, &(Map.get(&1, key) == value))
  end
end
