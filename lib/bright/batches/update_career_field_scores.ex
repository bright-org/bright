defmodule Bright.Batches.UpdateCareerFieldScores do
  @moduledoc """
  キャリアフィールドスコアを更新するバッチ。

  キャリアフィールドスコアは、大規模な集計のため、スキルスコア更新（画面操作）の度には更新せずにバッチによって更新する。
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerFields.CareerField
  alias Bright.Jobs.Job
  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits.SkillUnit
  alias Bright.Accounts.User
  alias Bright.SkillScores.{SkillScore, CareerFieldScore}

  def call do
    users = list_users()
    dict_skill_ids = map_skill_ids_career_field()
    dict_count = map_values_count(dict_skill_ids)
    career_fields = Repo.all(CareerField)

    users
    |> Enum.each(&upsert_career_field_scores(&1, career_fields, dict_skill_ids, dict_count))
  end

  # ユーザー単位のキャリアフィールドスコア更新処理
  defp upsert_career_field_scores(user, career_fields, dict_skill_ids, dict_count) do
    scores =
      career_fields
      |> Enum.map(fn career_field ->
        skill_ids = Map.get(dict_skill_ids, career_field.id) || []
        count = Map.get(dict_count, career_field.id) || 0
        high_skills_count = count_high_skills(user, skill_ids)
        percentage = if count == 0, do: 0.0, else: high_skills_count / count

        %{
          id: Ecto.ULID.generate(),
          user_id: user.id,
          career_field_id: career_field.id,
          high_skills_count: high_skills_count,
          percentage: percentage,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    placeholders = %{timestamp: timestamp}

    Repo.insert_all(
      CareerFieldScore,
      scores,
      placeholders: placeholders,
      on_conflict: {
        :replace,
        [:high_skills_count, :percentage, :updated_at]
      },
      conflict_target: [:user_id, :career_field_id]
    )
  end

  # score: highのレコード数取得
  defp count_high_skills(user, skill_ids) do
    from(
      skill_score in SkillScore,
      where: skill_score.user_id == ^user.id,
      where: skill_score.skill_id in ^skill_ids,
      where: skill_score.score == :high
    )
    |> Repo.aggregate(:count)
  end

  # 対象となるユーザーを取得
  defp list_users do
    from(user in User, where: not is_nil(user.confirmed_at))
    |> Repo.all()
  end

  # キャリアフィールド単位のskillsを取得
  # career_fields - jobs - skill_panels - ... - skills と関連が深いので分割取得している
  defp map_skill_ids_career_field do
    career_fields = list_career_fields()
    dict_skill_panels_job = map_jobs()
    dict_skill_units_skill_panel = map_skill_panels()
    dict_skills_skill_unit = map_skill_units()

    career_fields
    |> Map.new(fn career_field ->
      jobs = career_field.jobs
      skill_panels = Enum.flat_map(jobs, &Map.get(dict_skill_panels_job, &1.id))
      skill_units = Enum.flat_map(skill_panels, &Map.get(dict_skill_units_skill_panel, &1.id))

      skills =
        skill_units
        |> Enum.flat_map(&Map.get(dict_skills_skill_unit, &1.id))
        |> Enum.uniq()

      {career_field.id, Enum.map(skills, & &1.id)}
    end)
  end

  defp list_career_fields do
    from(
      career_field in CareerField,
      join: jobs in assoc(career_field, :jobs),
      preload: [jobs: jobs]
    )
    |> Repo.all()
  end

  defp map_jobs do
    from(
      job in Job,
      join: skill_panels in assoc(job, :skill_panels),
      preload: [skill_panels: skill_panels]
    )
    |> Repo.all()
    |> Map.new(&{&1.id, &1.skill_panels})
  end

  defp map_skill_panels do
    from(
      skill_panel in SkillPanel,
      join: skill_classes in assoc(skill_panel, :skill_classes),
      join: skill_units in assoc(skill_classes, :skill_units),
      preload: [skill_classes: {skill_classes, skill_units: skill_units}]
    )
    |> Repo.all()
    |> Map.new(fn skill_panel ->
      skill_units = Enum.flat_map(skill_panel.skill_classes, & &1.skill_units)
      {skill_panel.id, skill_units}
    end)
  end

  defp map_skill_units do
    from(
      skill_unit in SkillUnit,
      join: skill_categories in assoc(skill_unit, :skill_categories),
      join: skills in assoc(skill_categories, :skills),
      preload: [skill_categories: {skill_categories, skills: skills}]
    )
    |> Repo.all()
    |> Map.new(fn skill_unit ->
      skills = Enum.flat_map(skill_unit.skill_categories, & &1.skills)
      {skill_unit.id, skills}
    end)
  end

  defp map_values_count(map) do
    Map.new(map, fn {key, values} -> {key, Enum.count(values)} end)
  end
end
