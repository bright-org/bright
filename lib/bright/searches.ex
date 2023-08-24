defmodule Bright.Searches do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false

  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillScores.SkillClassScore
  alias Bright.UserJobProfiles.UserJobProfile

  def skill_search(user_id, {job_params, job_range_params, skill_params}) do
    user_ids =
      skill_score_query(user_id, job_params, job_range_params)
      |> skill_query(skill_params)
      |> Repo.all()
      |> filter_skill_class_and_level(skill_params)

    from(
      u in User,
      where: u.id in ^user_ids,
      preload: [:skill_class_scores, :user_job_profile]
    )
    |> Repo.all()
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
        skill_class: sc.class
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
          where: sc.skill_panel_id in ^Enum.map(skills, & &1.skill_panel),
          select: sc.id
        )
      )
    )
  end

  defp job_profile_query(user_id, job, job_range) do
    from(
      job in UserJobProfile,
      where: ^job,
      select: job.user_id
    )
    |> where([j], not (j.user_id == ^user_id))
    |> availability_date_query(job_range)
    |> desired_income_query(job_range)
  end

  # job_profile 稼働可能日
  defp availability_date_query(query, %{pj_start: start_date, pj_end: end_date}) do
    where(
      query,
      [job],
      ^start_date <= job.availability_date and job.availability_date <= ^end_date
    )
  end

  defp availability_date_query(query, %{pj_start: start_date}) do
    where(query, [job], ^start_date <= job.availability_date)
  end

  defp availability_date_query(query, %{pj_end: end_date}) do
    where(query, [job], job.availability_date <= ^end_date)
  end

  defp availability_date_query(query, _range_params), do: query

  # job_profile 希望年収
  defp desired_income_query(query, %{desired_income: income}) do
    where(query, [job], job.desired_income <= ^income)
  end

  defp desired_income_query(query, _range_params), do: query

  # スキルのclassとlevelでの絞り込み
  defp filter_skill_class_and_level(skill_scores, []), do: Enum.map(skill_scores, & &1.user_id)

  defp filter_skill_class_and_level(skill_scores, skills) do
    Enum.map(skills, fn params ->
      filter(skill_scores, :skill_panel_id, Map.get(params, :skill_panel))
      |> filter(:skill_class, class_nil_check(Map.get(params, :class)))
      |> filter(:level, level_to_atom(Map.get(params, :level)))
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()
    end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_key, val} -> val == Enum.count(skills) end)
    |> Enum.map(fn {key, _val} -> key end)
  end

  defp class_nil_check(class) when is_nil(class), do: nil
  defp class_nil_check(class), do: class
  defp level_to_atom(nil), do: nil
  defp level_to_atom(level), do: String.to_atom(level)

  defp filter(list, _key, nil), do: list

  defp filter(list, key, value) do
    Enum.filter(list, &(Map.get(&1, key) == value))
  end
end
